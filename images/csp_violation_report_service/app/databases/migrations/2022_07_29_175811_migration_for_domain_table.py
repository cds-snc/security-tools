"""MigrationForDomainTable Migration."""

from masoniteorm.migrations import Migration


class MigrationForDomainTable(Migration):
    def up(self):
        """
        Run the migrations.
        """
        with self.schema.create("domains") as table:
            table.uuid("id").primary()
            table.string("name")
            table.timestamps()

    def down(self):
        """
        Revert the migrations.
        """
        self.schema.drop("domains")
