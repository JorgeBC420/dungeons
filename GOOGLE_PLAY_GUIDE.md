# Google Play Console Guide - Calabozos: Guerra de Facciones

## Prerequisites

1. **Google Developer Account** ($25 one-time fee)
2. **Signed APK/AAB** build from Godot
3. **Assets** for Google Play:
   - App icon (512x512 PNG)
   - Feature graphics (1024x500 PNG)
   - Screenshots (minimum 2, max 8)
   - App description (4000 characters max)

## Step 1: Export Android Build

### In Godot Editor:
1. Project → Export
2. Add platform → Android
3. Configure:
   - **Release APK/AAB**:
     - Keystore path: Create new or use existing
     - Key password: Strong password (save it!)
     - Alias: your_app_alias
     - Alias password: Same as key password
4. Click Export and wait for build

### Build Commands (optional - for AAB format preferred by Google Play):
```bash
# First export to Android Gradle Project
# Then in the exported directory:
./gradlew bundleRelease
```

## Step 2: Create App on Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create App**
3. **App details**:
   - Name: "Calabozos: Guerra de Facciones"
   - Default language: Spanish
   - App category: Games > Card
   - Type: Free
4. Click Create

## Step 3: Set Up Store Listing

1. **Store listing** section:
   - **Title**: Calabozos: Guerra de Facciones
   - **Short description** (80 chars):
     ```
     Juega batallas de cartas en tiempo real contra la IA
     ```
   - **Full description**:
     ```
     Calabozos: Guerra de Facciones es un juego de estrategia 
     por turnos con cartas coleccionables.
     
     Características:
     • 27 cartas únicas de 3 facciones (Humanos, Orcos, Elfos)
     • Batalla contra IA inteligente
     • Sistema de progresión y niveles
     • 3 idiomas: Español, Inglés, Portugués
     • Seguridad anti-trampa
     
     Mecánicas de juego:
     - 3 carriles de batalla
     - Ventajas de facción +3 ATK
     - Habilidades especiales únicas por carta
     - Base con 20 puntos de vida
     
     Únete a la guerra de facciones y demuestra tu estrategia.
     ```
   - **Screenshots**: Upload 2-8 screenshots (language: Spanish)
   - **Feature graphics**: 1024x500 PNG
   - **Icon**: 512x512 PNG
   - **Category**: Strategy
   - **Content rating**: Complete questionnaire

## Step 4: App Release

1. **Internal testing**:
   - App releases → Internal testing
   - Upload AAB or APK
   - Add internal testers (Google accounts)
   - Test on devices

2. **Closed testing**:
   - Repeat internal testing process
   - Select 5-25 testers
   - Run for 1-2 weeks

3. **Open testing** (optional):
   - Public beta test
   - Unlimited testers

4. **Production release**:
   - Upload build to Production
   - Review and publish

## Step 5: Pricing & Distribution

1. **Pricing and distribution**:
   - Price: FREE
   - Countries: Select all or choose specific regions
   - Ads: None (no ads in our game)
   - Content rating: Complete and submit

2. **Target API level**:
   - Minimum: API 21 (Android 5.0)
   - Target: API 31+ (latest)

## Step 6: Review and Publish

1. Check **Program policies** compliance
2. Review **content rating**
3. Click **Publish**
4. Wait 2-24 hours for review (usually faster)

## Security & Anti-Cheat Configuration

Our game includes:
- ✅ Encrypted save files (AES-256)
- ✅ Anti-cheat validation
- ✅ Card data integrity checks
- ✅ Impossible stat detection
- ✅ Tamper attempt logging

### Play Console Security Settings:

1. **App security**:
   - Enable target API level enforcement
   - Enable 64-bit architecture requirement
   - Review app permissions

2. **Content ratings questionnaire**:
   - Violence: Select "Cartoon or Fantasy Violence"
   - Sexual content: None
   - Profanity: None

## App Signing Certificate

**Important**: Google Play will sign the final APK with your certificate.

Your certificate fingerprint:
```
SHA-256 fingerprint will be shown in Play Console
Save this for your records
```

## Post-Launch

1. **Monitor reviews** in Play Console
2. **Update version code** for new releases
3. **Track analytics** in User Acquisition section
4. **Check crashes** in Android Vitals
5. **Monitor daily active users (DAU)**

## Localization in Play Console

Español (es):
- Titlulo: "Calabozos: Guerra de Facciones"

English (en):
- Title: "Calabozos: Faction War"

Português (pt):
- Título: "Calabozos: Guerra das Facções"

## Testing URLs

After publishing, share this URL with testers:
```
https://play.google.com/store/apps/details?id=com.calabozos.guerrafacciones
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| APK rejected - Target API too low | Update targetSdkVersion to 31+ |
| Build fails - Keystore error | Recreate keystore or recover password |
| Upload blocked - 64-bit | Include 64-bit native libraries |
| Content policy violation | Review app for banned content |
| Crash on specific device | Test on Android 5.0+ devices |

## Support Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Godot Android Export Guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Google Play Policy Center](https://play.google.com/console/about/programs/policies/)
