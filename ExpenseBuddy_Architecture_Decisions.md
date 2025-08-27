# ExpenseBuddy - My Architectural Decisions & Why I Made Them

## Hey there!

So I built this personal finance app called ExpenseBuddy, and I want to walk you through the key decisions I made and why. I'm not gonna sugarcoat it - some choices were easy, some were tough, and some I'm still thinking about. Here's my honest take on what I built and why.

---

## 1. **Why Flutter + Firebase? (The Easy Choice)**

### **What I picked: Flutter + Firebase**

**Flutter was a no-brainer because:**
- I wanted to build for iOS, Android, Web, Windows, and macOS without losing my mind
- There are like 25,000+ packages out there - basically everything I needed was already built
- Hot reload is a game-changer when you're iterating fast
- The widget library is insane - I didn't have to build basic stuff from scratch

**Firebase made sense because:**
- I didn't want to spend weeks setting up a backend
- Real-time sync was built-in, which I knew I'd need
- I'm not a DevOps person, so "serverless" sounded perfect
- Authentication with Google/Apple Sign-In was literally 5 lines of code

**The trade-offs I'm worried about:**
- I'm kinda locked into Firebase now - if I want to move, it'll be painful
- It can get expensive if the app takes off
- I can't customize everything exactly how I want

**Bottom line:** I chose speed over flexibility. I wanted to build fast and see if people actually use this thing.

---

## 2. **State Management - The Hybrid Approach**

### **What I did: BLoC + Provider (mixed)**

**Here's why I didn't pick just one:**
- BLoC is great for complex stuff like user preferences and auth flows
- Provider is perfect for simple UI state and navigation
- I didn't want to over-engineer simple state management

**My thinking:**
- Pure BLoC would be overkill for simple stuff
- Provider alone doesn't give me the structure I need for complex logic
- This hybrid thing gives me the best of both worlds

**What I learned:**
- I considered Riverpod but went with Provider because the Flutter team endorses it
- BLoC makes testing way easier for the complex parts
- I'm happy with this choice so far

---

## 3. **Authentication - Separate Flows (The UX Win)**

### **What I built: Separate pages for email vs social login**

**Why I didn't put everything on one page:**
- Have you seen those cluttered login pages? They look terrible
- I wanted social login to be the main thing people see
- Email is just a fallback for people without social accounts

**My reasoning:**
- Most people use social login anyway, so make that the star
- Separate flows are easier to maintain and modify
- It just looks cleaner and more professional

**What I implemented:**
- Google Sign-In and Apple Sign-In for maximum coverage
- Email flow with proper validation (because people still use it)
- Social login reduces friction - people can get in with one tap

---

## 4. **Offline Support - Why I Ditched WorkManager**

### **What I built: SQLite + my own sync system**

**Why I went with SQLite:**
- Works instantly offline - no waiting around
- Super fast local queries
- No weird background service limitations
- Same behavior on all platforms

**Why I didn't use WorkManager:**
- It doesn't work well with the latest Flutter versions
- Setting it up was taking forever and I was getting frustrated
- Different behavior on iOS vs Android
- I'd have to keep fixing it every time Flutter updates

**My thought process:**
- WorkManager setup was killing my development speed
- I can build a custom sync system that does exactly what I need
- SQLite is rock solid and easy to work with

**What I built instead:**
- A queue system for pending operations
- Conflict resolution when data gets out of sync
- Using Flutter local notifications for background sync

---

## 5. **Database - The Dual Approach**

### **What I did: SQLite locally + Firebase Firestore in the cloud**

**Why both?**
- SQLite gives me offline functionality
- Firestore gives me real-time sync and cloud backup
- Local queries are fast, cloud gives me persistence
- I don't have to worry about scaling

**My thinking:**
- One database would limit what I can do offline
- This gives me the best of both worlds
- Firestore's offline persistence works well with my local SQLite

**What I implemented:**
- Data versioning to handle conflicts
- Proper indexing for performance
- Migration system for when I need to change the database structure

---

## 6. **UI Design - Going iOS Style**

### **What I picked: Cupertino design language**

**Why not Material Design?**
- Material Design feels very Android-centric
- I want iOS users to feel at home
- Cupertino looks more professional for a financial app
- iOS users are more likely to pay for premium apps

**My reasoning:**
- I'm targeting people who care about design
- iOS users expect certain interactions
- It just looks cleaner and more modern

**What I built:**
- Dark/light mode that switches automatically
- Responsive design for all screen sizes
- Custom widgets that maintain consistency

---

## 7. **Navigation - GoRouter FTW**

### **What I used: GoRouter with nested navigation**

**Why GoRouter?**
- Declarative routing is way cleaner than Navigator 2.0
- Deep linking just works
- Handles complex navigation hierarchies
- Performance is great

**My thinking:**
- Navigator 2.0 is way too complex for what I need
- GoRouter gives me modern routing without the headache
- Nested navigation works perfectly for my tab-based interface

**What I built:**
- Route guards for authentication
- Deep linking for sharing specific app states
- Error handling routes for when things go wrong

---

## 8. **Package Management - Keeping It Simple**

### **What I use: Just Flutter Pub**

**Why not any other tools?**
- Flutter Pub is the official tool
- I don't need the complexity of multiple package managers
- It handles Flutter packages perfectly
- Less things to go wrong

**My reasoning:**
- Flutter Pub is the standard - why fight it?
- Single package manager means less conflicts
- Official Flutter team support means it'll keep working

**What I learned:**
- pubspec.yaml manages everything
- Dependencies get resolved automatically
- Regular updates keep things secure

---

## 9. **Testing - Keeping It Light**

### **What I do: Unit tests + Widget tests**

**Why not full integration tests?**
- Integration tests slow down my development cycle
- Firebase integration tests are a pain to set up
- They use way too many resources
- I'm building a prototype, not launching to Mars

**My approach:**
- Focus on testing the important business logic
- Widget tests verify UI behavior
- I can add integration tests later when I'm ready for production

**What I built:**
- BLoC pattern makes unit testing easy
- Widget tests check UI interactions
- Mock services for testing without external dependencies

---

## 10. **Performance - Lazy Loading All The Way**

### **What I implemented: Lazy loading + efficient state management**

**Why this approach?**
- App starts fast because I'm not loading everything upfront
- Memory usage stays low
- Smooth user experience
- Handles large datasets without crashing

**My thinking:**
- Eager loading would make the app feel slow
- Lazy loading gives better user experience
- Efficient state management prevents unnecessary rebuilds

**What I built:**
- Pagination for transaction lists
- Image caching to reduce network requests
- Background processing for heavy operations

---

## 11. **Security - Firebase + Local Encryption**

### **What I did: Firebase security rules + local encryption**

**Why this combination?**
- Firebase security is battle-tested
- Local encryption adds another layer of protection
- Meets financial app requirements
- I don't have to maintain security updates

**My reasoning:**
- Building custom security would take forever
- Firebase gives me industry-standard security
- Local encryption protects sensitive data on the device

**What I implemented:**
- Secure storage for sensitive user data
- Regular security audits
- User consent and privacy compliance

---

## 12. **Deployment - Codemagic Makes It Easy**

### **What I use: Multi-platform build + Codemagic CI/CD**

**Why Codemagic?**
- It's built specifically for Flutter
- Automatically builds for all platforms
- Minimal configuration needed
- Handles the complexity I don't want to deal with

**My thinking:**
- Platform-specific deployment would be a nightmare
- Codemagic gives me Flutter-native CI/CD
- Multi-platform build ensures consistent experience

**What I get:**
- Automatic builds for iOS, Android, Web, Windows, and macOS
- Platform-specific optimizations
- PWA capabilities for web
- Automated testing before deployment

---

## **So What Did I Learn?**

The decisions I made for ExpenseBuddy were all about **speed, user experience, and not over-engineering things**. Yeah, I'm locked into Firebase and some other choices, but I can build and ship fast. The hybrid approach to state management, separate auth flows, and offline-first architecture show I actually thought about what users need.

**What worked well:**
- Flutter let me build fast across all platforms
- Firebase eliminated backend headaches
- Codemagic made deployment painless
- Offline-first means the app always works
- Separate auth flows look way better

**What I'm thinking about for the future:**
- I might need to figure out how to get away from Firebase if it gets too expensive
- WorkManager might be worth revisiting once Flutter compatibility improves
- I should probably add more integration tests before going to production
- Analytics and user tracking could be interesting

**Bottom line:** I prioritized getting something working fast over perfect architecture. Sometimes you just need to ship and see what happens. The app works, users like it, and I can always refactor later.
