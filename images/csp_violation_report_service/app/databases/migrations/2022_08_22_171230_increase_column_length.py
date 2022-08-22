"""IncreaseColumnLength Migration."""

from masoniteorm.migrations import Migration


class IncreaseColumnLength(Migration):
    def up(self):
        """
        Run the migrations.
        """
        with self.schema.table("reports") as table:
            table.string("original_policy", length=8190).change()

    def down(self):
        """
        Revert the migrations.
        """
        with self.schema.table("reports") as table:
            table.string("original_policy").change()
