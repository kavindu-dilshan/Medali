# 💊 Medali - Smart Medication Tracker  
*A project for SE4041 – Mobile Application Design and Development (Assignment 02)*

<img src="https://github.com/kavindu-dilshan/Medali/blob/main/Medali/Medali.png" alt="Medali">

Medali is an iOS application that helps users track their daily medications, receive timely reminders, log taken/skipped doses, and monitor their adherence over time. The app integrates **Core Data**, **Local Notifications**, and **HealthKit** to deliver a personalized medication-tracking experience.

---

### ✨ Features
- **Add new medications** with:
  - Name  
  - Dosage  
  - Optional notes  
  - One or more daily reminder times
    
- **Daily reminders via Local Notifications**
  - Scheduled for each medication time
  - Alerts appear even when the app is backgrounded/locked
  - Remove all scheduled reminders when a medication is deleted

- **Medication dashboard**
  - List of all medications with times and color-coded pill cards
  - Overall progress ring
  - Today’s step count using **HealthKit**

- **Medication detail screen**
  - Individual progress ring
  - Mark doses as **Taken** or **Skipped**
  - Optional notes for each log
  - Full dose history with timestamps & icons

- **Dose logging**
  - Taken / Skip actions stored in Core Data
  - Relationship-based model (Medication → DoseLog)

- **Delete medications**
  - Swipe-to-delete
  - Automatically cancels all scheduled reminders

---

### 🛠️ Technologies & Frameworks

| Technology | Purpose |
|-----------|---------|
| **SwiftUI** | UI Layout, Views, Navigation |
| **Core Data** | Persistent storage for medications, times & logs |
| **Local Notifications** | Daily medication reminders |
| **HealthKit** | Step count insights |
| **MVVM Architecture** | Clean separation of UI, logic & services |

---

### 🧑‍💻 Architecture & Design

- MVVM pattern
- EnvironmentObjects for shared services
- Reactive UI updates powered by SwiftUI
- Adaptive dark mode + dynamic type
- Accessible controls with VoiceOver labels

---

### 📄 License

This project is for academic use as part of SE4041 – Mobile Application Design and Development.
Feel free to explore the code but avoid direct copying without attribution.

