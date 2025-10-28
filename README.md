Learner App
An elegant iOS app built with SwiftUI and MVVM architecture that helps you track your daily learning progress across different subjects and time periods.

Features
🧠 Daily Learning Tracker: Log your learning sessions and monitor your progress.
📅 Flexible Periods: Choose between weekly, monthly, or yearly tracking modes.
🎯 Progress Visualization: Beautiful progress rings and activity views.
🏆 Celebration Sheets: Unlock motivational sheets after completing 7-day, 30-day, or 365-day streaks.
💾 Local Data Persistence: Progress saved using UserDefaults for seamless user experience.
🌈 Custom UI Design: Minimal black background, gradient overlays, and Apple-style animations.

App Architecture
The project follows a clean MVVM (Model–View–ViewModel) structure:
Learner/
 ┣ 📁 Models/
 ┃ ┗ DayLog.swift
 ┣ 📁 ViewModels/
 ┃ ┗ ActivityVM.swift
 ┣ 📁 Views/
 ┃ ┣ ContentView.swift
 ┃ ┣ ActivityView.swift
 ┃ ┗ FreezeSheetView.swift
 ┗ 📁 Assets.xcassets/
Model: Defines data types like DayLog and learning periods.
ViewModel: Manages state and logic for progress tracking.
View: Builds SwiftUI interfaces for smooth navigation and animations

How to Run
Clone this repository:
git clone https://github.com/<your-username>/Learner.git
Open the project in Xcode.
Make sure the device target is set to iPhone Simulator or your real iPhone.
Press Run ▶️ to build and launch the app.

Requirements
Xcode: 15.0 or later
iOS: 17.0 or later
Swift: 5.9 or later
🎨 Design Language
The Learner app uses:
A clean black background for focus.
Custom gradients and accent borders (selectedBGend, accentBorder).
Apple-style layout spacing and smooth transitions.
💡 Future Improvements
Add CloudKit sync for multi-device progress tracking.
Implement widgets for daily reminders.
Integrate Game Center achievements.
👩‍💻 Author
Fatmah Ibrahim
Designer & iOS Developer
📍 Saudi Arabia
📧 Faitmh.ab@gmail.com
🪄 License
This project is licensed under the MIT License — feel free to use, modify, and share
