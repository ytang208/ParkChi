# ParkChi

ParkChi is an offline-first Chicago parking companion for iPhone. It helps a driver remember where they parked, keep a photo of the posted sign, schedule a move-the-car alert, record street-cleaning reminders, and track vehicle-renewal dates.

The app does **not** interpret parking signs or determine whether a parking space is legal. Users are always reminded to verify posted signs and official rules.

## What works in this first build

- Save and clear one current parking spot.
- Capture the current location only when requested.
- Open the saved location in Apple Maps.
- Attach a parking-sign photo from the photo library.
- Set a local move-by notification.
- Create one-time or weekly street reminders.
- Track city sticker, license plate, residential permit, emissions-test, and custom deadlines.
- Receive local renewal notifications 30, 7, and 1 day before a future deadline.
- Keep all app records locally on the iPhone—no account or server.

## Run it on a Mac

1. Install the latest Xcode from the Mac App Store.
2. Open `ParkChi.xcodeproj`.
3. Select the ParkChi project, then the ParkChi target, then **Signing & Capabilities**.
4. Choose your Apple developer team and replace `com.yourname.ParkChi` with a bundle identifier you control, such as `com.yourname.parkchi`.
5. Choose an iPhone simulator from the device menu and press the triangular Run button.
6. To test location, photos, and notifications properly, connect an iPhone, trust the Mac, select the iPhone, and press Run.

A free Apple account can be used for early testing on your own device. TestFlight and App Store distribution require the paid Apple Developer Program.

## Test before sharing

- Allow and deny location access; both paths must remain usable.
- Allow and deny notifications; saved records must still work.
- Save a spot with and without a location, photo, note, and move time.
- Open the saved location in Maps.
- Restart the app and confirm that everything remains saved.
- Add and delete street reminders and renewal dates.
- Test with large text and dark mode.
- Confirm that no content or buttons are covered on the smallest supported iPhone simulator.

## Recommended next releases

1. Test the current app with 5–10 Chicago drivers.
2. Improve the parking workflow based on observed confusion.
3. Add editing for existing street reminders and renewals.
4. Add official Chicago street-sweeping data only after confirming data reliability and licensing.
5. Add privacy-safe analytics, then a restrained ad placement after repeat usage is proven.

Do not add advertising before the core workflow is stable. Any future advertising SDK will change the app's privacy disclosures and must be tested with Apple's current review rules.
