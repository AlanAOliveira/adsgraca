import sys
import site

# Add virtual environment site-packages
site.addsitedir('/var/www/ABOS/venv/lib/python3.11/site-packages')
sys.path.insert(0, '/var/www/ABOS')

from app import app as application
