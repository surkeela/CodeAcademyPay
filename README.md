FinalProject - CodeAcademyPay

Replica of classing banking application (Revolut, for example)

Your goal as a developer is not only to make it work and fulfil formal requirements, but also to make it as beautiful and user-friendly as possible. It means that you should choose appropriate UI elements to make input effortless for the user, use robust validation logic, error handling etc. We did not lay out all possible functionalities, failure scenarios, scene layout etc. - everything is left for you to decide. If we did not tell that you should not let user to input letters, unlimited numbers etc. to the phone number field - it does not mean that we will not require this. It means that we expect from you as future developers to understand this implicitly and choose appropriate solutions.

To summarize - you need to handle all errors, all failure scenarios. You need to build UI that not only works and does what expected, but also looks good for the user. Also, although everything can be achieved using primitive methods (functions, logic, UI elements etc.), this should not be your goal and you should aim to make it as good as you possibly can. Imagine that you are creating an app to be published in App Store and you have a lot of competitors. You need to make your app the best in the market in order to generate profit.

Build this app to show the knowledge and skills you learned during the course. You need to fulfill the described requirements and you are also encouraged to expand different parts of the application if you find it interesting or necessary.

API

We will be using our made API: https://codeacademypay.fly.dev/api/ . This mean that it could have some errors. For you, as a future developer, we expect that you could possibly identify the API's bottlenecks, error and possibly improvements. The API is a subject to change during the evaluation, so you should make your app as easy as possible to adapt and aprove to upcoming API changes.

Endpoints

/users /transactions

More documentation will be provided with sample Postman documentation. You should first try-out and understand the API before starting programing.

Scenes

Login

Fields:

Phone number
Password
Submit button
On Submit:

Check if user with this phone number exists (/user)
Check if password is correct (/user)
GET /users/login to get access token and its expiration. Save access token and expiration in the app. Renew (GET new one) when it expires
Register

Fields:

Name
Phone number
Password
Confirm password
Currency
Submit button
On Submit:

Create user (/users)
Validation:

Before submitting, check if values in fields are valid
Home

When home screen opens, load current account transactions (where current account is sender or receiver) and related accounts from API and save to local storage

Fields:

Current account balance with currency
Add money button
Send Money button
Settings button
Transaction List (Shows 5 newest transactions loaded from local storage) with See all button, which would load all transaction (in a separate window, or how do you want, it does not matter)
Transaction List

Show all current account transactions loaded from local storage

Search field which filters transaction list based on input (by note, by phone number)
Filter button
Clear filter button (clears search and filter)
Transaction Filter

Date (range)
Amount (range)
Currency
Outgoing or incoming transactions
Transaction Info

Outgoing or incoming transaction
Formatted date
Sender phone number (logical to show this only on incoming transactions)
Receiver phone number (logical to show this only on outgoing transactions)
Note (reference)
Amount and currency
Repeat button (Opens prefilled Send Money scene) (logical to show this only when you are sender)
Add Money

Enter amount and PUT new balance (/transactions)
Send Money

Recipient phone number
Prefill sender currency
Add note (reference)
Enter sum
Validation

Check if recipient exists
Check if recipient currency is equal to your currency
Check if your sender balance is sufficient
After validation

Create new trasaction and POST (/transaction)
Change sender Account balance
Settings

Update password (/user)
Update currency (/account)
Logout
Technical Requirements

General

Do not forget about Swift style guides (either Ray Wenderlich - https://github.com/raywenderlich/swift-style-guide or Google - https://google.github.io/swift/)
Do not forget about access control (private, internal, public etc.)
Use subclassing, where it is relevant and needed
Use extensions, split huge functions into smaller ones (if possible)
When you finish some part of the functionality, take a look of what you have already written and check if you can refactor something and make it look cleaner
Differentiate between structs and classes by situation (do not mix them - use struct where struct is best, use class where class is best)
Functions with clear purpose, without unexpected side-effects
Use “weak” when needed
Networking

Setting up a basic networking layer using URLSession is encouraged, however, you can also use 3rd party libraries for networking (such as Alamofire), if you want
Storage

Use UserDefaults, Keychain and CoreData where needed
Fetch and save transactions and accounts locally
Create a relationship between Transaction and Account
In API, transaction has fields for sender and receiver ids. In local storage, keep reference to sender and receiver Account instead of ids
UI

You are free to make any UI based on the requirements. You can use your favourite banking application as an inspiration.

Application should only support Vertical orientation
Application should support all screen sizes, all required elements should fit
Write UI programatically or use Xibs / Storyboards
Use UINavigationController for navigating between scenes
Use self-sizing cells, scroll views, keyboard appearing notification and visual effects (rounded corners, shadows, borders, gradients) where appropriate
You can write progamatic UI constraints by using Apple methods or using SnapKit (or other 3rd party constraint wrapper library)
Architecture

There is no requirement to use specific app architecture. However, code needs to be split into independent single-purpose components and layers. API/Storage layers should not contain UI code and UI layer should not contain API/Storage code.

Presentation

Prepare a 10-12 minute presentation of the project. You can use slides, video, or screen-sharing. Present the functionality of the application and explain how you executed it from the technical side.

Date of presentation 2023-12-06

Code analysis and feedback

You will sit down together with the lecturer to discuss certain parts of the code in your project. Be prepared to answer technical questions about coding and architectural patterns used in the application. Even if you reuse code from our previous projects, make sure you understand how and why it works.

Example questions:

Why did you make your delegate variable weak in this class? What would happen if you don't?
You have an implicly unwrapped variable in this function, what would happen if the value was nil at runtime?
When network response comes, you send a result through closure to notify about the result. Why couldn't you just simply return a result when it comes?
You will receive technical feedback as well.

Date of this session 2023-12-06

Evaluation

You will get 2 marks:

Practice (execution of the project from both user and code side)
Theory (understanding of coding and architectural patterns used in the application)
When evaluating the practice side we will continue looking at the project from all these angles:

User side - we will be your application users and see if we can break them. We will check if everything works as expected, there are no unhandled scenarios, there are no crashes or other things that could affect user experience
Code functionality - this is similar to user functionality testing but this time we will go into your code and check if everything is handled correctly code-wise. We will check if you used appropriate things for specific tasks, if there are no loopholes, if everything is handled correctly etc. In other words, we will check how you implement requirements code-wise
Code cleanliness - in this part we will check is your code clean. Do you split your functions, do you use extensions, if code is structured correctly, if you use proper naming, is styling okay etc
Technologies

We expect you to see the usage of:

for loops
clean functions
closures
delegates
enums
structs
do catch blocks
During the calculation of final result we will check on swift language features learned during the course and used in project

Deadline

The work needs to be sent as an archive to Domantas and Tadas via Teams private message until 2023-12-05 18:00:00
