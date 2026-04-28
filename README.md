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
- **Universal FTP Server:** Built-in server allowing any PC to connect via standard FTP clients (WinSCP, FileZilla) or Windows File Explorer.
- **Integrated Connection Guide:** A step-by-step tutorial inside the app to help users connect their computers effortlessly.
- **Emulator Support:** Fully compatible with ADB port forwarding for development and testing.

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

1.  **🌍 Multi-Language Support (l10n):** Full internationalization to make the app accessible globally (In Progress).
2.  **🌐 Web-Based Transfer:** Host a tiny web server on the phone so PCs can download files via a standard web browser (no FTP software needed).
3.  **📜 Transfer History:** A dedicated section to track all previous transfers with timestamps and file details.
4.  **🔒 Biometric Security:** Option to lock the app or specific folders with Fingerprint or Face ID.
5.  **📦 Smart Compression:** Automatically ZIP large folders on the fly before sending to save time and bandwidth.
6.  **👥 Group Sharing:** Support for sending files to multiple devices simultaneously.

---

## 🔧 Technical Details

- **Minimum SDK:** 21 (Required for QR Scanning and modern networking)
- **State Management:** Provider
- **Icons:** HugeIcons (Custom Stroke Style)
- **Storage Access:** `MANAGE_EXTERNAL_STORAGE` for full device browsing.

---

Built with ❤️ using **Flutter**.
