import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("iverilog") and shutil.which("vvp") and shutil.which("tclsh"),
                     "Icarus Verilog and Tcl are required")
class PipelineTests(unittest.TestCase):
    def run_copy(self, mutate=False):
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(ROOT, repo, ignore=shutil.ignore_patterns(".git", "reports", "__pycache__"))
            if mutate:
                rtl = repo / "src/rtl/opto_filter.v"
                rtl.write_text(rtl.read_text().replace("8'h32", "8'hff"))
            run = subprocess.run(["tclsh", str(repo / "scripts/run_sim.tcl")],
                                 cwd=temp, capture_output=True, text=True)
            return run, (repo / "reports/index.html").read_text()

    def test_clean_checkout_from_unrelated_directory(self):
        run, report = self.run_copy()
        self.assertEqual(run.returncode, 0, run.stdout + run.stderr)
        self.assertIn("Hardware verification: PASS", report)
        self.assertIn("Checks: 14", report)

    def test_incorrect_rtl_fails_and_still_generates_report(self):
        run, report = self.run_copy(mutate=True)
        self.assertNotEqual(run.returncode, 0)
        self.assertIn("Hardware verification: FAIL", report)


class ParserTests(unittest.TestCase):
    def test_empty_or_incomplete_log_cannot_pass(self):
        for log in ("", "[SYSTEM] SIMULATION_START\\n"):
            with self.subTest(log=log), tempfile.TemporaryDirectory() as temp:
                repo = Path(temp)
                (repo / "scripts").mkdir()
                (repo / "reports").mkdir()
                shutil.copy(ROOT / "scripts/parse_results.pl", repo / "scripts")
                (repo / "reports/sim.log").write_text(log)
                run = subprocess.run(["perl", str(repo / "scripts/parse_results.pl")],
                                     capture_output=True, text=True)
                self.assertNotEqual(run.returncode, 0)


if __name__ == "__main__":
    unittest.main()
