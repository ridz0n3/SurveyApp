## Development ##
1. Clone Repo 
2. Ensure you have Apple developer account
3. Ensure you have downloaded Certificate at [Apple Developer](https://developer.apple.com/account)

## Tools Development ##
1. Xcode Version 9.2 - iOS development tools
 
     * You can get [here](https://developer.apple.com/download/) (need have apple developer account or just install from App Store)
     * Then you install it, no need to be configured.
     * It ready to used.

2. Postman - for api checking purpose

     * You can get [here](https://www.getpostman.com/)
     * Then you install it.
     * Do like image below, set its method, endpoint, header(if needed), and body(if needed). After fill it, click send and API will give a response. ![Screen Shot 2018-02-23 at 7.29.51 AM.png](https://bitbucket.org/repo/jgRjz86/images/933735435-Screen%20Shot%202018-02-23%20at%207.29.51%20AM.png)

## Debugging ##
1. To debug first select "1" and select "2" at line where do you want to debug. (refer image below)
![Screen Shot 2018-02-22 at 3.23.42 PM.png](https://bitbucket.org/repo/jgRjz86/images/1779602634-Screen%20Shot%202018-02-22%20at%203.23.42%20PM.png)

## Rebuild ##
1. To rebuild the app after you change some code, first select device that you want to use and click run/play icon , or ``` cmd + r ```
![Screen Shot 2018-02-22 at 3.23.28 PM.png](https://bitbucket.org/repo/jgRjz86/images/953423973-Screen%20Shot%202018-02-22%20at%203.23.28%20PM.png)

## Deployment ##
1. To deploy app to itunes just open terminal(in mac)/CMD(in windows) and type ```
fastlane ios beta
``` and enter! (make sure you're in project folder)
2. If you doesn't install fastlane you can refer [Here](https://docs.fastlane.tools/)
3. And waiting it finish upload
       
       **To Invite user to testflight**

1. You can follow instruction from this [Doc](https://help.apple.com/itunes-connect/developer/#/dev839fb66e9)

       **To Submit to App Store**

4. After finish upload, open [iTunes Connect](https://itunesconnect.apple.com/) and login
5. Click 'My Apps' and choose your app
   ![Screen Shot 2018-02-23 at 3.58.21 PM.png](https://bitbucket.org/repo/jgRjz86/images/3860167922-Screen%20Shot%202018-02-23%20at%203.58.21%20PM.png)
6. And fill all detail that Apple want. For screenshot image size, you can refer [Here](http://help.apple.com/itunes-connect/developer/#/devd274dd925)
7. Choose your build by click + icon
   ![Screen Shot 2018-02-23 at 3.59.15 PM.png](https://bitbucket.org/repo/jgRjz86/images/614690160-Screen%20Shot%202018-02-23%20at%203.59.15%20PM.png)
8. After finish all click ```Submit for review```
9. Apple review will take maximum 1 weeks minimum 1 day for their approval
10. If Apple approve it, you can release it to App Store
11. If they reject it, you must fix that issue that they reject
4. Good Luck!