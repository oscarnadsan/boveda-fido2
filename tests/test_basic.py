"""Non-cryptographic smoke tests. Hardware integration tests must run manually."""
import importlib.machinery
import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path

SOURCE = Path(__file__).resolve().parents[1] / 'src' / 'boveda'
loader = importlib.machinery.SourceFileLoader('boveda_cli', str(SOURCE))
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)


class Basics(unittest.TestCase):
    def test_docx_valid(self):
        with tempfile.TemporaryDirectory() as folder:
            dest = Path(folder) / 'test.docx'
            mod.create_docx(dest)
            with zipfile.ZipFile(dest) as z:
                self.assertIsNone(z.testzip())
                self.assertIn('word/document.xml', z.namelist())

    def test_names(self):
        for name in ('../private', '/tmp/x', '.hidden', 'a/b', 'a\\b'):
            with self.assertRaises(RuntimeError):
                mod.nombre_seguro(name)
        self.assertEqual(mod.nombre_seguro('apuntes.docx'), 'apuntes.docx')


if __name__ == '__main__':
    unittest.main()
