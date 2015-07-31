# EFTools
iOS Tools for ElevenFifty

## How to use EFTools
If you are already using Cocoapods, this is easy. If you aren't - then start!  Here's a sample Podfile that uses EFTools:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
xcodeproj 'testapp.xcodeproj'

pod 'EFTools', :git => 'https://github.com/ElevenFifty/EFTools.git', :branch => '0.1'
```

EFTools has many dependencies that will be pulled down for you.  They are as follows:
* AFDateHelper (https://github.com/melvitax/AFDateHelper)
* AlamoFire (https://github.com/Alamofire/Alamofire)
* MBProgressHUD (https://github.com/jdg/MBProgressHUD)
* ParseFacebookUtils
* ParseUI (by default this also pulls in Parse)
* SnapKit (http://snapkit.io/docs/)
* SwiftyJSON (https://github.com/SwiftyJSON/SwiftyJSON)

By default, EFTools pulls down all of these.  You can also pull down subsets with the following Podfile lines:

1. pod 'EFTools/Basic', :git => 'https://github\.com/ElevenFifty/EFTools.git', :branch => '0.1'
  * pulls down AFDateHelper, MBProgressHUD, and SnapKit
2. pod 'EFTools/Parse', :git => 'https://github\.com/ElevenFifty/EFTools.git', :branch => '0.1'
  * pulls down ParseUI/Parse, ParseFacebookUtils, and everything that "Basic" pulls down
3. pod 'EFTools/Alamofire', :git => 'https://github\.com/ElevenFifty/EFTools.git', :branch => '0.1'
  * pulls down Alamofire, SwiftyJSON, and everything that "Basic" pulls down


##Features
####Easier UIColors
Gone are the days of having to divide doubles to get your UIColors by hex.  Where you used to do this:
```
let color = UIColor(red: 100.0/255.0, green: 25.0/255.0, blue: 63.0/255.0, alpha: 1.0)
```
Now you can do this:
```
// define your own alpha
let color = UIColor.rgba(100, green: 25, blue: 63, alpha: 1.0)
// or default alpha to 1.0
let color2 = UIColor.rgb(100, green: 25, blue: 63)
```

####Quick Spinners
Have something that's going to take a while in your project?  Add a spinner:
```
ProgressUtilities.showSpinner(self.view)
// or
ProgressUtilities.showSpinner(self.view, title: "Loading")
```

If you want to edit more properties of the spinner, you can get direct access to it:
```
ProgressUtilities.showSpinner(self.view, title: "Loading")
let hud = ProgressUtilities.getHud()!
hud.labelColor = UIColor.greenColor()
```

And don't forget to hide it when you are done with it!
```
ProgressUtilities.hideSpinner()
```

####Table View Controllers
Depending on whether you are using Parse or not, EFTools contains two different kinds of table view controllers:
* EFTableViewController - subclasses UITableViewController
* EFQueryTableViewController - subclasses PFQueryTableViewController

These subclasses do two things:
* Document specific methods of each subclass you may want to override and why
* Provide quick access to animated cells

After subclassing either of these classes for your own use, you can Option-click on each class to view their documentation and see important methods to override.

Here's a quick code example, which you would set up in viewDidLoad, to show how to set up cell animations.  Further details can be seen by looking at each class's documentation:

```
setCellType([.Scale, .Fade])
setInitialAlpha(0.5)
setInitialScale(1.5, yscale: 1.5)
setShowType(ShowType.Reload)
setDuration(0.5)
setInitialAlpha(0.25)
```

This example will fade the cells in while making them scale down to their proper size.  Each of these effects have defaults, which are available in each class's documentation.
