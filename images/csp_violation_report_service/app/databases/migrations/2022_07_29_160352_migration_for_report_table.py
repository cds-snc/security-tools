"""MigrationForReportTable Migration."""

from masoniteorm.migrations import Migration


class MigrationForReportTable(Migration):
    def up(self):
        """
        Run the migrations.
        """
        with self.schema.create("reports") as table:
            table.uuid("id").primary()
            table.string("domain")
            table.string("document_uri")
            table.string("referrer")
            table.string("violated_directive")
            table.string("original_policy")
            table.string("blocked_uri")

            table.timestamps()

    def down(self):
        """
        Revert the migrations.
        """
        self.schema.drop("reports")
