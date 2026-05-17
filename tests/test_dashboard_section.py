import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HTML = (ROOT / "index.html").read_text(encoding="utf-8")


class DashboardSectionTest(unittest.TestCase):
    def test_dashboard_section_is_present_and_linked_from_navigation(self):
        self.assertIn('href="#dashboard"', HTML)
        self.assertIn('<section class="dashboard" id="dashboard"', HTML)
        self.assertIn('CSV-powered progress dashboard', HTML)

    def test_dashboard_uses_kan_29_export_fields_and_realistic_seeded_metrics(self):
        expected_copy = [
            'workout_date',
            'exercise',
            'volume',
            'rest_since_previous_set_seconds',
            '21 completed workouts',
            '84 logged sets',
            '7 months tracked',
            '3 days/week',
        ]

        for copy in expected_copy:
            with self.subTest(copy=copy):
                self.assertIn(copy, HTML)

    def test_dashboard_explains_the_value_of_tracking_before_advanced_analytics(self):
        expected_copy = [
            'See what actually changed',
            'Training effort becomes evidence',
            'Progress is no longer a feeling',
        ]

        for copy in expected_copy:
            with self.subTest(copy=copy):
                self.assertIn(copy, HTML)


if __name__ == "__main__":
    unittest.main()
