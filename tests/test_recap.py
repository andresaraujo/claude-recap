"""Parser tests against a hand-made transcript. Run: python3 -m unittest discover tests"""
import unittest
from importlib.machinery import SourceFileLoader
from pathlib import Path

HERE = Path(__file__).parent
recap = SourceFileLoader("recap", str(HERE.parent / "bin" / "recap")).load_module()


class Turns(unittest.TestCase):
    def setUp(self):
        self.pairs = recap.turns(HERE / "fixture.jsonl", 10)

    def test_only_real_prompts_with_replies(self):
        self.assertEqual([p for p, _ in self.pairs], ["fix the port check for IPv6", "(ran /digest)"])

    def test_final_reply_is_text_after_last_tool_call(self):
        self.assertTrue(self.pairs[0][1].startswith("Fixed."))
        self.assertNotIn("Looking at", self.pairs[0][1])

    def test_sidechain_and_garbage_lines_ignored(self):
        self.assertEqual(self.pairs[1][1], "Digest is ready.")

    def test_last_n(self):
        self.assertEqual(len(recap.turns(HERE / "fixture.jsonl", 1)), 1)


class Clean(unittest.TestCase):
    def test_strips_code_urls_backticks(self):
        out = recap.clean("Fixed. See `a.sh` and https://x.y/z.\n```\nboom\n```", 500)
        self.assertNotIn("boom", out)
        self.assertNotIn("https://", out)
        self.assertIn("a.sh", out)


if __name__ == "__main__":
    unittest.main()
