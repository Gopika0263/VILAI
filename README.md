# 🌾 VILAI — விலை | Farmer Market Price Intelligence

<p align="center">
  <img src="assets/app_logo.png" alt="VILAI Logo" width="100"/>
</p>

<p align="center">
  <strong>Empowering Indian Farmers with AI-Powered Price Intelligence</strong><br/>
  Built with Flutter • Groq AI • Real Government Data
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.0-blue?logo=dart" />
  <img src="https://img.shields.io/badge/AI-Groq%20LLaMA%203.3%2070B-orange" />
  <img src="https://img.shields.io/badge/Data-data.gov.in-green" />
  <img src="https://img.shields.io/badge/Platform-Android-brightgreen?logo=android" />
</p>

---

## 📌 Problem

In India, **60 crore farmers** face a critical challenge:

> A farmer sells tomatoes for ₹20/kg → Middlemen sell to restaurants at ₹60/kg → **Farmer loses ₹40 profit per kg**

Farmers also lack access to:
- Real-time market prices
- Price trend predictions
- Direct buyer connections
- Government scheme information

---

## 💡 Solution — VILAI (விலை = Price)

VILAI is a **mobile-first farmer intelligence app** that gives farmers:
- ✅ **Real mandi prices** from Government API
- ✅ **ML-powered price predictions** (Linear Regression + Groq AI)
- ✅ **Direct buyer marketplace** — no middleman
- ✅ **Tamil voice AI chatbot** — speak and get answers
- ✅ **Weather-based farming advice**
- ✅ **Government schemes & loan guidance**
- ✅ **Multi-language support** (Tamil, English, Hindi, Telugu, Kannada)

---

## 📱 Screenshots

| Home Screen | Price Prediction | AI Chatbot |
|:-----------:|:----------------:|:----------:|
| Weather + Features | ML Line Chart | Voice Input |

| Markets | Government Schemes | Loans |
|:-------:|:-----------------:|:-----:|
| Live Prices | 12 Schemes | 8 Loan Options |

---

## 🚀 Features

### 1. 📈 AI Price Prediction
- Fetches **real historical prices** from `data.gov.in`
- Runs **Linear Regression** (y = mx + b) on real data
- Calculates **R² accuracy score**
- **Groq LLaMA 3.3 70B** validates and gives Tamil advice
- Shows: "When to sell for maximum profit?" in selected language

### 2. 🤖 Tamil Voice AI Chatbot
- Powered by **Groq LLaMA 3.3 70B** (fastest AI)
- **Speech-to-Text** input in Tamil (`speech_to_text`)
- **Text-to-Speech** output in Tamil (`flutter_tts`)
- Answers about crop prices, farming tips, market rates

### 3. 🏪 Live Market Prices
- Real mandi prices from **Government of India API** (`data.gov.in`)
- Weather per market from **OpenWeatherMap API**
- Transport profit calculator — "Which market gives best profit after transport cost?"
- Best market recommendation

### 4. 🤝 Direct Farmer-Buyer Marketplace
- Farmers post crop listings (crop, quantity, price, grade, location)
- Buyers browse and **call/WhatsApp directly**
- Zero middleman — 100% profit to farmer

### 5. 🌦️ Weather-Based Advice
- Real weather from farmer's **registered location**
- Farming advice: "Safe to go to market?" / "Rain warning!"
- Beautiful blue gradient weather card

### 6. 🏛️ Government Schemes
- 12 government schemes (Central + Tamil Nadu State)
- PM-KISAN, Crop Insurance, KCC, Solar Pump, Uzhavar Sandhai
- Complete guide: eligibility, documents, how to apply

### 7. 🏦 Farmer Loan Schemes
- 8 loan options with lowest interest rates
- KCC (4%), Gold Loan (4%), NABARD, SBI, Indian Bank, Canara
- Step-by-step application guide

### 8. 🌐 Multi-Language Support
- **5 languages**: Tamil, English, Hindi, Telugu, Kannada
- Instant switch — entire app changes language in real-time
- No app restart required

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Mobile Framework** | Flutter 3.24 / Dart 3.0 |
| **AI Model** | Groq LLaMA 3.3 70B Versatile |
| **Market Data API** | data.gov.in (Government of India) |
| **Weather API** | OpenWeatherMap |
| **Location** | ip-api.com (free, no permissions) |
| **Speech Input** | speech_to_text ^6.6.0 |
| **Voice Output** | flutter_tts ^3.8.5 |
| **Charts** | fl_chart ^0.65.0 |
| **Notifications** | flutter_local_notifications ^17.0.0 |
| **ML Algorithm** | Linear Regression (custom Dart implementation) |
| **State Management** | ChangeNotifier + ListenableBuilder |

---

## 🧠 ML Algorithm

Price prediction uses a custom **Linear Regression** implementation in Dart:

```dart
// Formula: y = mx + b
slope     = (n·ΣXY - ΣX·ΣY) / (n·ΣX² - (ΣX)²)
intercept = (ΣY - slope·ΣX) / n

// R² accuracy score
R² = 1 - (SS_residual / SS_total)

// Prediction
price(day) = slope × (n - 1 + day) + intercept
           clamped to ±20% of last real price
```

**Data Pipeline:**
```
data.gov.in API → Real Tamil Nadu mandi prices
      ↓
Linear Regression → Trend direction + R² score
      ↓
Groq LLaMA 3.3 → Validate + Tamil advice
      ↓
fl_chart LineChart → Historical + Regression + Predicted lines
```

---

## 📦 Installation

### Prerequisites
- Flutter SDK 3.24+
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/vilai-app.git
cd vilai-app/nilai_app

# 2. Install dependencies
flutter pub get

# 3. Add your API keys in lib/constants.dart
# (See API Keys section below)

# 4. Run the app
flutter run
```

### API Keys

Create or update `lib/constants.dart`:

```dart
const String kGroqApiKey    = 'YOUR_GROQ_API_KEY';
const String kGovApiKey     = 'YOUR_DATA_GOV_IN_API_KEY';
const String kWeatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
```

**Get API Keys (all free):**
| API | URL | Free Tier |
|-----|-----|-----------|
| Groq AI | https://console.groq.com | Free — fastest LLM |
| data.gov.in | https://data.gov.in/user/register | Free government data |
| OpenWeatherMap | https://openweathermap.org/api | 60 calls/minute free |

---

## 📁 Project Structure

```
nilai_app/
├── assets/
│   ├── app_logo.png
│   ├── farmer_hero.png
│   └── register.png
├── android/
│   └── app/src/main/AndroidManifest.xml
├── lib/
│   ├── main.dart                    # App entry, navigation shells
│   ├── constants.dart               # API keys, colors, crop data
│   ├── models/
│   │   ├── chat_message.dart
│   │   └── market_data.dart
│   ├── services/
│   │   ├── auth_service.dart        # Login/Register (in-memory)
│   │   ├── groq_service.dart        # Groq AI API
│   │   ├── weather_service.dart     # OpenWeatherMap
│   │   ├── market_service.dart      # data.gov.in
│   │   ├── notification_service.dart
│   │   └── language_service.dart   # Multi-language translations
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth_screen.dart         # Login / Register
│   │   ├── home_screen.dart         # Dashboard + Weather
│   │   ├── prediction_screen.dart   # ML Price Prediction
│   │   ├── chat_screen.dart         # Voice AI Chatbot
│   │   ├── markets_screen.dart      # Live Market Prices
│   │   ├── schemes_screen.dart      # Government Schemes
│   │   ├── loan_screen.dart         # Farmer Loans
│   │   ├── farmer_listing_screen.dart
│   │   ├── buyer_screen.dart
│   │   ├── profile_screen.dart
│   │   └── language_screen.dart    # Language Selector
│   └── widgets/
│       └── bouncing_dots.dart
└── pubspec.yaml
```

---

## 🏆 Hackathon Build

Built for **hackathon** to solve real farmer problems in Tamil Nadu, India.

### Key Innovations:
1. **Real data only** — no fake/simulated prices, ever
2. **Tamil voice AI** — farmers speak, AI answers in Tamil
3. **Transport profit calculator** — unique feature no other app has
4. **ML + AI hybrid** — Linear Regression on real data, validated by LLaMA 3.3
5. **Zero middleman** — direct farmer-to-buyer connection
6. **5-language support** — instant switch, no restart

### Pitch Summary:
> *"VILAI gives farmers the right price, right time, and right buyer — using real government data and Tamil AI — so they keep 100% of their profit."*

---

## 🔐 Android Permissions

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

---

## 🌱 Future Roadmap

- [ ] Firebase Authentication (persistent login)
- [ ] Push notifications for price alerts
- [ ] More crops (Banana, Coconut, Sugarcane)
- [ ] More languages (Malayalam, Marathi, Bengali)
- [ ] Offline mode with cached prices
- [ ] FPO (Farmer Producer Organization) features
- [ ] Integration with PM-KISAN portal

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

```bash
git checkout -b feature/your-feature
git commit -m "Add your feature"
git push origin feature/your-feature
```

---

## 📄 License

MIT License — feel free to use and modify for farmer welfare projects.

---

## 👨‍💻 Built With ❤️ for Indian Farmers

> *"உழைக்கும் கைகளுக்கு சரியான விலை"*
> *"The right price for hardworking hands"*

---
## Team members
- Kanishka 
- Saranya
- Gopika

<p align="center">
  Made with Flutter 🐦 • Powered by Groq AI ⚡ • Data from Government of India 🇮🇳
</p>
