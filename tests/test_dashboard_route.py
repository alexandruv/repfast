import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOME_HTML = (ROOT / "index.html").read_text(encoding="utf-8")
DASHBOARD_PATH = ROOT / "dashboard" / "index.html"
DASHBOARD_HTML = DASHBOARD_PATH.read_text(encoding="utf-8") if DASHBOARD_PATH.exists() else ""


class DashboardRouteTest(unittest.TestCase):
    def test_dashboard_has_real_route_from_home_page(self):
        self.assertTrue(DASHBOARD_PATH.exists(), "/dashboard/index.html should back repfast.pomeloapps.com/dashboard")
        self.assertIn('href="/dashboard/"', HOME_HTML)
        self.assertIn('RepFast Training Dashboard', DASHBOARD_HTML)

    def test_dashboard_is_grounded_in_kan_29_seeded_export_data(self):
        expected_values = [
            '23,280 lb',
            '21 workouts',
            '84 sets',
            '7 months',
            'Oct 2025',
            'Apr 2026',
            '2025-10-03',
            '2026-04-24',
            '2,415',
            '6,720',
            '2,535',
            'Leg Press',
            '10,770',
            'Lat Pulldown',
            '4,305',
        ]

        for value in expected_values:
            with self.subTest(value=value):
                self.assertIn(value, DASHBOARD_HTML)

    def test_dashboard_contains_useful_training_analysis_surfaces(self):
        expected_sections = [
            'Volume trend',
            'Exercise contribution',
            'Workout consistency',
            'Rest discipline',
            'Best lift trend',
            'Training block verdict',
            'Download CSV from the app',
        ]

        for section in expected_sections:
            with self.subTest(section=section):
                self.assertIn(section, DASHBOARD_HTML)

    def test_dashboard_is_not_generic_marketing_copy(self):
        required_domain_copy = [
            'Based on the fake KAN-29 export seeded in the app',
            'workout_date',
            'exercise',
            'volume',
            'rest_since_previous_set_seconds',
            '3 sessions in the same week each month',
        ]

        for copy in required_domain_copy:
            with self.subTest(copy=copy):
                self.assertIn(copy, DASHBOARD_HTML)


if __name__ == "__main__":
    unittest.main()
