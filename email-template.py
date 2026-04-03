#!/usr/bin/env python3
"""Convert built newsletter HTML to inline-styled email HTML."""
import re, json, sys

if len(sys.argv) < 2:
    print("Usage: email-template.py <built-html-file> [brief-url]", file=sys.stderr)
    sys.exit(1)

with open(sys.argv[1], "r") as f:
    html = f.read()

brief_url = sys.argv[2] if len(sys.argv) > 2 else ""

# CSS class to inline style mapping
replacements = {
    'class="newsletter-header"': 'style="background:#ffffff;padding:32px 20px 24px;border-bottom:2px solid #2563eb;"',
    'class="newsletter-header-inner"': 'style="display:block;"',
    'class="newsletter-title"': 'style="font-size:22px;font-weight:800;color:#111827;letter-spacing:-0.5px;"',
    'class="newsletter-subtitle"': 'style="font-size:14px;font-weight:600;color:#2563eb;margin-top:2px;"',
    'class="newsletter-date"': 'style="font-size:13px;color:#4b5563;margin-top:8px;"',
    'class="newsletter-theme"': 'style="padding:20px 20px 12px;"',
    'class="bullet-card"': 'style="margin:6px 20px;background:#ffffff;border-radius:10px;border:1px solid #e5e7eb;padding:20px;"',
    'class="bullet-inner"': 'style="display:block;"',
    'class="bullet-number"': 'style="font-size:28px;font-weight:800;color:#2563eb;line-height:1;margin-bottom:8px;"',
    'class="bullet-content"': '',
    'class="bullet-headline"': 'style="font-size:15px;font-weight:700;color:#111827;font-family:Georgia,serif;margin-bottom:8px;"',
    'class="bullet-analysis"': 'style="font-size:13px;color:#4b5563;line-height:1.7;margin:0;padding-left:18px;list-style:none;"',
    'class="bullet-source"': 'style="margin-top:10px;font-size:11px;color:#9ca3af;"',
    'class="newsletter"': 'style="max-width:680px;margin:0 auto;"',
    'class="newsletter-footer"': 'style="padding:20px;text-align:center;"',
    'class="newsletter-footer-title"': 'style="font-size:11px;color:#9ca3af;letter-spacing:1px;font-weight:600;"',
    'class="newsletter-footer-meta"': 'style="font-size:11px;color:#d1d5db;margin-top:4px;"',
}
for cls, style in replacements.items():
    html = html.replace(cls, style)

# Inline link styles
html = html.replace('<a href=', '<a style="color:#111827;text-decoration:none;border-bottom:1px solid #e5e7eb;" href=')

# Inline theme paragraph style
html = re.sub(
    r'(<div style="padding:20px 20px 12px;">)<p>',
    r'\1<p style="font-size:14px;color:#4b5563;line-height:1.6;background:#fff;border-radius:8px;padding:14px 16px;border:1px solid #e5e7eb;margin:0;">',
    html,
)

# Strip document wrapper, keep content
html = re.sub(
    r'<!DOCTYPE html>.*?<body>',
    '<div style="font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif;max-width:680px;margin:0 auto;background:#ffffff;">',
    html, flags=re.DOTALL,
)
html = html.replace('</body>', '</div>')
html = html.replace('</html>', '')
html = re.sub(r'<link[^>]*>', '', html)

# Add view-in-browser footer
if brief_url:
    html += f'''
<div style="padding:20px;text-align:center;border-top:1px solid #e5e7eb;margin-top:8px;">
  <div style="font-size:11px;color:#9ca3af;letter-spacing:1px;font-weight:600;">AI IN MARKETING: 5 BULLET FRIDAY</div>
  <div style="font-size:11px;color:#d1d5db;margin-top:4px;">Curated weekly &middot; <a href="{brief_url}" style="color:#2563eb;text-decoration:none;">View in browser</a></div>
</div>
'''

# Output as JSON string for curl -d consumption
print(json.dumps(html))
