"""
Django command to wait for the db to be available
"""
import time

from psycopg2 import OperationalError as Psycopg2OpError

from django.db.utils import OperationalError
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    """Django command to wait db"""

    def handle(self, *args, **kwargs):
        """Entrypoint for the command"""
        self.stdout.write('Waiting database...')
        db_up = False
        while db_up is False:
            try:
                time.sleep(1)
                self.check(databases=['default'])
                db_up = True
            except (Psycopg2OpError, OperationalError):
                self.stdout.write('Database unavailable, waiting 1 second ...')

        self.stdout.write(self.style.SUCCESS('Database available!'))
