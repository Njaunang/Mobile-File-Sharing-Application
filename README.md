# Local Sharer 📁🚀

**Local Sharer** is a professional, high-performance file sharing application built with Flutter. Inspired by industry leaders like Xender, it enables seamless, high-speed file transfers between mobile devices and PCs using advanced P2P technology and standard FTP protocols.

---

## 🎨 Modern UI & Experience
The application features a complete redesign with a focus on professional aesthetics and intuitive UX:
- **Sleek Dashboard:** Categorized grid for Apps, Images, Videos, Music, and Documents.
- **Fluid Animations:** Smooth transitions and interactive elements powered by `flutter_animate`.
- **Adaptive Dark Mode:** A deep slate theme optimized for low-light environments and battery saving.
- **In-App Previews:** Open and preview files directly within the app before sharing.

## 🚀 Key Features

### 1. Advanced P2P Transfer (Mobile-to-Mobile)
- **Zero Configuration:** Uses **mDNS (Network Service Discovery)** to automatically find nearby devices on the same Wi-Fi.
- **Custom TCP Protocol:** Optimized for maximum speed and reliability during high-volume transfers.
- **QR Code Connectivity:** Instant "Scan-to-Connect" system that bypasses manual credential entry.
- **Secure Handshake:** User-defined authentication (Username/Password) for every peer-to-peer session.
- **Real-time Progress:** Live progress bars and status updates for both sender and receiver.

### 2. Built-in File Explorer
- **Deep Storage Access:** Navigate the entire internal storage (`/storage/emulated/0/`) without leaving the app.
- **Multi-Selection:** Select multiple files or entire folders to send in one batch.
- **Smart Categorization:** Automatically filters files by type for quick access.
- **Breadcrumb Navigation:** Easy folder jumping and path tracking.

### 3. PC Connection (Mobile-to-PC)
- **Secure Web Share (NEW):** Host a modern, responsive web portal directly from your phone. Any PC on the same network can access it via a standard browser using a **4-digit Security PIN**.
- **Universal FTP Server:** Built-in server allowing legacy connection via standard FTP clients (WinSCP, FileZilla) or Windows File Explorer.
- **QR Access:** Scan the on-screen QR code to instantly open the web share portal on other devices.
- **Integrated Connection Guide:** A step-by-step tutorial inside the app to help users connect their computers effortlessly.
- **Emulator Support:** Fully compatible with ADB port forwarding for development and testing.

### 4. 🕘 Transfer History
- **Persistent Logs:** Dedicated section to track all previous transfers (sent and received).
- **Timeline UI:** Beautifully organized history with timestamps, file sizes, and status.
- **Instant Access:** Open received files directly from the history page using `open_filex`.

### 5. 🔐 Biometric Security
- **App-Wide Protection:** Lock the entire application with Fingerprint, Face ID, or a 6-digit Master PIN.
- **Secure Vault (Private Safe):** A hidden, encrypted section in the explorer to store sensitive files. Files moved here are isolated from other apps.
- **Automatic Auto-Lock:** The app automatically locks when moved to the background or minimized.
- **Customizable Logic:** Toggle between biometric and PIN authentication in the settings.

---

## 📖 Usage Guide

### Mobile-to-Mobile Sharing
1. **Receiver:** Tap **RECEIVE** on the bottom bar, set your credentials, and click **START WAITING**.
2. **Sender:** Select your files in the **Files** category or explorer, tap **SEND**, and then tap the **QR Icon** at the top right.
3. **Connect:** Scan the Receiver's QR code to instantly start the transfer.

### Mobile-to-PC Transfer
1. Toggle the **Connect to PC** switch on the dashboard.
2. Tap the **"How to connect?"** icon for the exact IP address and steps.
3. **For Emulators:**
   - Run `adb forward tcp:2121 tcp:2121`
   - Run `adb forward tcp:2122 tcp:2122`
   - Connect to `ftp://127.0.0.1:2121`

---

## 🔮 Future Evolutions (Roadmap)

To take **Local Sharer** even further, we are looking at the following improvements:

## . 📦 Smart Compression

Implement automatic compression for large folders before transfer.

Requirements:

* detect large folders automatically
* compress to ZIP in real time before sending
* show compression progress indicator
* reduce bandwidth and transfer time
* preserve folder structure

Please ensure:

* no UI blocking
* asynchronous background processing
* memory-efficient compression logic
* strong error handling

---

# 🎨 UI / UX Requirements

The UI and UX must be **perfect, modern, and highly professional**.

I want:

* smooth animations
* polished transitions
* clean modern cards
* premium file manager style interface
* responsive design
* intuitive navigation
* beautiful progress indicators
* professional typography
* modern icons (HugeIcons)

The design should feel close to:

* Xender
* ShareIt
* AirDrop style experience

---

# 🛡 Backend / Security Requirements

This is extremely important.

The backend logic must be:

* clean
* scalable
* maintainable
* highly secure
* free from known vulnerabilities
* robust against future security threats

Please pay special attention to:

* secure file handling
* socket safety
* authentication flow
* server lifecycle
* concurrency
* null safety
* error prevention
* memory leaks
* production-level architecture

I want **excellent code quality with minimal risk of future bugs or security issues**.

Please structure the code professionally with clear separation of:

* UI
* services
* models
* controllers / providers
* utilities
* storage
* security



---

## 🔧 Technical Details

- **Minimum SDK:** 21 (Required for QR Scanning and modern networking)
- **State Management:** Provider
- **Icons:** HugeIcons (Custom Stroke Style)
- **Storage Access:** `MANAGE_EXTERNAL_STORAGE` for full device browsing.

---

Built with ❤️ using **Flutter**.
