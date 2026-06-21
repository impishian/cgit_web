#!/Library/Frameworks/Python.framework/Versions/3.13/bin/python3


# This script uses Pygments and Python3. You must have both installed
# for this to work.
#
# http://pygments.org/
# http://python.org/
#
# It may be used with the source-filter or repo.source-filter settings
# in cgitrc.
#
# The following environment variables can be used to retrieve the
# configuration of the repository for which this script is called:
# CGIT_REPO_URL        ( = repo.url       setting )
# CGIT_REPO_NAME       ( = repo.name      setting )
# CGIT_REPO_PATH       ( = repo.path      setting )
# CGIT_REPO_OWNER      ( = repo.owner     setting )
# CGIT_REPO_DEFBRANCH  ( = repo.defbranch setting )
# CGIT_REPO_SECTION    ( = section        setting )
# CGIT_REPO_CLONE_URL  ( = repo.clone-url setting )


import sys
import io
from pathlib import Path
import markdown
from pygments import highlight
from pygments.util import ClassNotFound
from pygments.lexers import TextLexer
from pygments.lexers import guess_lexer
from pygments.lexers import guess_lexer_for_filename
from pygments.formatters import HtmlFormatter


sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')


def decode_source(data):
	lines = []
	for line in data.splitlines(keepends=True):
		try:
			lines.append(line.decode('utf-8-sig'))
		except UnicodeDecodeError:
			lines.append(line.decode('gb18030', errors='ignore'))
	return ''.join(lines)


data = decode_source(sys.stdin.buffer.read())
filename = sys.argv[1]
formatter = HtmlFormatter(style='default', nobackground=True)


def is_markdown_file(path):
	return Path(path).suffix.lower() in {'.md', '.markdown', '.mdown', '.mkd'}


if is_markdown_file(filename):
	html = markdown.markdown(
		data,
		extensions=[
			'markdown.extensions.fenced_code',
			'markdown.extensions.codehilite',
			'markdown.extensions.tables',
			'markdown.extensions.sane_lists',
		],
		extension_configs={
			'markdown.extensions.codehilite': {'css_class': 'highlight'},
		},
	)
	sys.stdout.write('<div class="markdown-body">')
	sys.stdout.write(html)
	sys.stdout.write('</div>')
	sys.exit(0)

try:
	lexer = guess_lexer_for_filename(filename, data)
except ClassNotFound:
	# check if there is any shebang
	if data[0:2] == '#!':
		lexer = guess_lexer(data)
	else:
		lexer = TextLexer()
except TypeError:
	lexer = TextLexer()

# highlight! :-)
# printout pygments' css definitions as well
sys.stdout.write('<style>')
sys.stdout.write(formatter.get_style_defs('.highlight'))
sys.stdout.write('</style>')
sys.stdout.write(highlight(data, lexer, formatter, outfile=None))
