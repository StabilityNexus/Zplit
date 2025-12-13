# Zplit Website

Static marketing website for the Zplit decentralized payment-splitting app.

## 📁 Structure

```
website/
├── index.html              # Main landing page
├── .well-known/
│   └── assetlinks.json     # Android App Links configuration
├── css/
│   └── styles.css          # Minimalistic green theme
├── js/
│   └── main.js             # Smooth scroll & animations
├── assets/
│   └── images/             # Logos, illustrations, mockups
└── README.md               # This file
```

## 🎨 Design

- **Theme:** Minimalistic with green hues (#10B981)
- **Typography:** Inter font family
- **Responsive:** Mobile-first design
- **Accessibility:** Semantic HTML, proper contrast ratios

## 🚀 Deployment

### Option 1: GitHub Pages

1. Push the `website/` directory to your repository
2. Go to **Settings** → **Pages**
3. Set source to `main` branch, `/website` folder
4. Your site will be live at `https://stabilitynexus.github.io/Zplit/`

### Option 2: Vercel

```bash
cd website
vercel --prod
```

### Option 3: Netlify

1. Drag and drop the `website/` folder to [Netlify Drop](https://app.netlify.com/drop)
2. Or connect your GitHub repository

### Option 4: Custom Server (Nginx)

```nginx
server {
    listen 80;
    server_name zplit.stability.nexus;
    root /var/www/zplit/website;
    index index.html;

    location /.well-known/assetlinks.json {
        default_type application/json;
    }
}
```

## 🔗 Android Deep Linking Setup

1. **Generate SHA256 Fingerprint:**

```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore
keytool -list -v -keystore /path/to/release.keystore -alias your-alias
```

2. **Update `assetlinks.json`:**

Replace `PLACEHOLDER_REPLACE_WITH_ACTUAL_SHA256_FINGERPRINT` with your actual SHA256 fingerprint.

3. **Verify Deep Linking:**

```bash
# Test assetlinks.json accessibility
curl https://your-domain.com/.well-known/assetlinks.json

# Validate with Google's tool
https://developers.google.com/digital-asset-links/tools/generator
```

## 🧪 Local Testing

### Simple HTTP Server (Python)

```bash
cd website
python -m http.server 8000
# Visit http://localhost:8000
```

### Live Server (VS Code Extension)

1. Install "Live Server" extension
2. Right-click `index.html` → "Open with Live Server"

## 📝 Customization

### Update Colors

Edit CSS variables in `css/styles.css`:

```css
:root {
    --primary-green: #10B981;  /* Change to your brand color */
    --dark-green: #059669;
    --light-green: #D1FAE5;
}
```

### Replace Placeholder Images

- `assets/images/zplit-logo.png` - Replace with final logo
- `assets/images/app-mockup.png` - Replace with actual app screenshots
- `assets/images/hero-illustration.png` - Update with final design

### Update Content

Edit `index.html` sections:
- Hero tagline and description
- Feature cards
- How It Works steps
- Community links

## 🔧 Maintenance

- **SEO:** Update meta tags in `<head>` section
- **Analytics:** Add tracking code in `js/main.js`
- **Performance:** Optimize images (use WebP format)
- **Security:** Ensure HTTPS for deep linking to work

## 📄 License

This website is part of the Zplit project.  
© 2025 The Stable Order

## 🤝 Contributing

See the main [Zplit repository](https://github.com/StabilityNexus/Zplit) for contribution guidelines.
