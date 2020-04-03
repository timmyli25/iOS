Final Project ReadMe
Timmy Li
Dangerous

To get the app working again, go to Chicago Crime portal and register for your own app token.
Then go and place that app token in CrimeUtilities.swift

Testing:
To test just build the app in Xcode as usual. You may have to use the simulator to simulate a location in Chicago. You can use Lat: 41.786505 and Long: -87.606142 for as an example.

I have also provided a chicago.gpx file. This file will allow you to simulate movement around an area close to the University. Notifications are sent once the number of crimes within the distance threshold is equal to or greater than the crime threshold. The grader may want to change the "120.0"(2 minutes) in the locationManager function of MapViewController to something lower so that they can see the notifcations more often. I wanted to make this notification time limit a setting, but ran out of time.

Something is weird about my Xcode. Sometimes I need to restart it several times before it allows me to simulate locations. It may be the case for you. You may have to restart it.

Use the tool popover view to adjust the distance and crime count threshold. Also use that popover to filter for a specific type of crime. Finally, the popover view allows the user to recenter the map on their location.

Note:
One unforseen circumstance is that the Chicago Crime portal API uses an app token. Here I have my own app token hardcoded in. Ideally, for the user, the app would register an app token for them. I did not have the time to implement this. I will delete this app token after final grades are submitted.

Further, I could not figure out how to fix the MobileGestalt.c:1647: Could not retrieve region info error message. According to some sources online, it is a bug, but I cannot be sure.

Sources:

1. Fire image:
https://www.google.com/search?q=fire+image&tbm=isch&ved=2ahUKEwjGk-bNxpboAhURY60KHYjmDTMQ2-cCegQIABAA&oq=fire+image&gs_l=img.3..0l10.14507.20137..20283...0.0..0.91.645.10......0....1..gws-wiz-img.......35i39j0i67.x8n5Iu6DmqQ&ei=uwNrXobKNZHGtQWIzbeYAw&rlz=1C5CHFA_enUS865US865#imgrc=FkwSQeezSmuo1M

2. Location Manager Example:
https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift

3. How to send Notifications:
https://programmingwithswift.com/how-to-send-local-notification-with-swift-5/

4. Showing an activity spinner:
https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening

5. Syncing settings bundle with plist.
https://stackoverflow.com/questions/46453789/swift-4-settings-bundle-get-defaults/46537668

6. Tool for generating simulated Chicago movement:
https://www.gpxgenerator.com/

7. Tool for generating app icons
https://appicon.co/

