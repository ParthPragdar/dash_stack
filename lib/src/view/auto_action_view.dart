import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../dash_stack.dart';
import '../controller/master_controller.dart';
import '../utils/string.dart';
import '../service/api_call.dart';
import '../utils/error_js.dart';

class AutoActionView extends StatefulWidget {
  final Map<String, dynamic> actionElement;
  const AutoActionView({super.key, required this.actionElement});

  @override
  AutoActionViewState createState() => AutoActionViewState();
}

class AutoActionViewState extends State<AutoActionView> {
  late final WebViewController controller;
  bool isLoadJs = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            log("onProgress =>$progress");
          },
          onPageStarted: (String url) {
            if (!isLoadJs) readJS();
          },
          onPageFinished: (url) {
            if (kDebugMode) {
              print(url);
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.actionElement['url'] ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }

  readJS() async {
    isLoadJs = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      MasterController.to.readJSFileByUrl(widget.actionElement['js_path'] ?? "", onCallBack: (jsContent) {
        debugPrint("-=-===jsContent-=-=-=>$jsContent");
        String scriptData = jsContent;
        if (scriptData.isEmpty) {
          scriptData = errorJs;
        }
        controller.runJavaScript(scriptData);
        Timer.periodic(
          const Duration(seconds: 30),
          (timer) {
            MasterController.to.updateActivity(
              data: {
                "u_token": storage.read(CS.sUserToken),
                "package_name": DashStack.instance.packageName,
                "url_id": widget.actionElement['url_id'],
                "activity_time": 30
              },
            );
          },
        );
      });
    });
  }

  String customJs2 = '''
  
function randomDelay(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function removeAdsByClass(className) {
  var elements = document.getElementsByClassName(className);
  // Using a while loop and live HTMLCollection to handle removal correctly
  while (elements.length > 0) {
    elements[0].parentNode.removeChild(elements[0]);
  }
}
// Define a function to observe changes in the DOM
function observeDOMChanges() {
  var targetNode = document.body;

  // Create a MutationObserver instance
  var observer = new MutationObserver(function (mutationsList) {
    let shouldCheckAds = false;
    for (var mutation of mutationsList) {
      if (mutation.type === "childList") {
        // Mark that we need to check for ads
        shouldCheckAds = true;
      }
    }
    // Check for ads if any child nodes were added
    if (shouldCheckAds) {
      setTimeout(() => {
        // removeAdsByClass("adsbygoogle");
        removeAdsByClass("adsbygoogle-noablate");
      }, 5000); // Adjust the timeout as needed to ensure delayed ads are caught
    }
  });

  // Configuration of the observer:
  var config = { childList: true, subtree: true };
  observer.observe(targetNode, config);
}
observeDOMChanges();

let executed = false; // Flag to track whether the code has been executed

function clickRandomListItem() {
  const ulElement = document.querySelector(
    "body > div > div > div.quizCard_body__Nm_87 > div > ul"
  );
  // Your existing code block
  if (!ulElement) {
    // Scroll to random positions 3-4 times with an interval of 2 seconds between each scroll
    var randomTimes = Math.floor(Math.random() * 2) + 3;
    var interval = 2000;
    setTimeout(() => {
      scrollMultipleTimesAndThenTop(randomTimes, interval);
      setTimeout(() => {
        clickPlayButton();
        setTimeout(() => {
          clickContestRulesLink();
        }, 9000);
      }, 13000);
    }, 3000);
  }
  const listItems = ulElement.querySelectorAll("li");
  const randomIndex = Math.floor(Math.random() * listItems.length);
  listItems[randomIndex].click();
}
clickRandomListItem();

// Function to execute clickRandomListItem with a delay
function clickWithDelayItem() {
  if (!executed) {
    // Execute only if not already executed
    const ulElement = document.querySelector(
      "body > div > div > div.quizCard_body__Nm_87 > div > ul"
    );
    if (!ulElement) {
      executed = true; // Set the flag to true if ulElement is not found
      return; // Stop execution if ulElement is not found
    }
    executed = true; // Set the flag to true after executing once
    setTimeout(() => {
      clickRandomListItem();
      setTimeout(() => {
        clickRandomListItem();
        setTimeout(() => {
            document.querySelector("body > div > div > div.playNow_playNow__HQEAM > a").click();
        }, 7000);
      }, 7000);
    }, 7000);
  }
}
clickWithDelayItem();

var body = document.querySelector("body");
function scrollToRandom() {
  var randomPosition = Math.floor(Math.random() * document.body.scrollHeight);
  document.documentElement.scrollTo({
    top: randomPosition,
    behavior: "smooth",
  });
}

function scrollToTop() {
  document.documentElement.scrollTo({
    top: 0,
    behavior: "smooth",
  });
}

function scrollMultipleTimesAndThenTop(times, interval) {
  let count = 0;

  function performScroll() {
    if (count < times) {
      scrollToRandom();
      count++;
      setTimeout(performScroll, interval);
    } else {
      setTimeout(scrollToTop, interval);
    }
  }

  performScroll();
}

function clickPlayButton() {
  const buttons = document.querySelectorAll(
    ".quizList_btn__bQLHf.quizList_btnSmall__Exetl"
  );
  if (buttons.length === 0) {
    console.error("No buttons found with the specified class");
    return;
  }

  const randomIndex = Math.floor(Math.random() * buttons.length);
  const selectedButton = buttons[randomIndex];
  selectedButton.scrollIntoView({
    behavior: "smooth",
    block: "center",
    inline: "nearest",
  });

  setTimeout(() => {
    selectedButton.click();
  }, 2000); // Adjust the delay time (in milliseconds) as needed
}

function clickContestRulesLink() {
  const contestRulesLink = document.querySelector(
    "body > div > div > div.playNow_twoBtn__nC11F > a"
  );
  if (contestRulesLink) {
    contestRulesLink.scrollIntoView({
      behavior: "smooth",
      block: "start",
      inline: "nearest",
    });
    setTimeout(() => {
      contestRulesLink.click();
      setTimeout(() => {
        scrollToBottom();
      }, 3000);
    }, 2000); // Adjust the delay time (in milliseconds) as needed
  } else {
    console.error("Contest Rules link not found");
  }
}

function scrollToBottom() {
  const bottomElement = document.body;
  bottomElement.scrollIntoView({
    behavior: "smooth",
    block: "end",
    inline: "nearest",
  });
  setTimeout(() => {
    clicBackButton();
    setTimeout(() => {clicBackButton();
      var randomTimes = Math.floor(Math.random() * 2) + 3;
      var interval = 2000;
      setTimeout(() => {
        scrollMultipleTimesAndThenTop(randomTimes, interval);
      },5000);
    }, 5000);
  }, 5000);
}

function clicBackButton() {
  const clicBackButton = document.querySelector(
    "body > div > div > header > div.header_logo__4Zn2n > nav > label > img "
  );
  if (clicBackButton) {
    clicBackButton.click();
  } else {
    console.error("Back Button not found");
  }
}

  ''';

  String customJs1 = '''
  
   function randomDelay(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

  
let clickingInProgress = false; 
function simulateClick(element) {
    if (!clickingInProgress && element) {
        clickingInProgress = true; 
        element.addEventListener('click', function(event) {
            event.preventDefault();
            console.log('Clicked on:', element.alt);
            clickingInProgress = false; 
        });
        element.click();
    } else {
        console.log('Element not found or clicking in progress.');
    }
}


function clickProceedButton() {
    let proceedButton = document.querySelector('[data-testid="proceed-button"]');
    if (proceedButton) {
        proceedButton.click();
        console.log("Clicked on the proceed button.");
        setTimeout(clickStartButton,6000); // Delay before clicking start button
    } else {
        console.error("Proceed button not found.");
    }
}

function clickStartButton() {
  let startButton = document.querySelector(".defaultButton");
  if (startButton) {
    startButton.click();
    setTimeout(scrollRandomElement, 5000);
    console.log("Clicked on the Start Now button.");
    setTimeout(clickCreateQuizButton, randomDelay(12000, 16000));
  } else {
    console.error("Start Now button not found.");
  }
}

function scrollRandomElement() {
  const scrollContainer = document.getElementById("shell");
  const scrollelemetn = scrollContainer.childNodes[2];
  console.log(scrollelemetn);
  scrollelemetn.childNodes[
    Math.floor(Math.random() * scrollelemetn.childNodes.length)
  ].scrollIntoView({ behavior: "smooth" });
  setTimeout(scrollToTop, 3000);
}

function scrollToTop() {
  console.log("Top");
  const scrollContainer = document.getElementById("shell");
  scrollContainer.childNodes[0].scrollIntoView({ behavior: "smooth" });
}


function clickCreateQuizButton() {
    let createQuizButton = document.querySelector('[data-testid="create-quiz-button"]');
    if (createQuizButton) {
        createQuizButton.click();
        console.log("Clicked on the Create Quiz button.");
        setTimeout(clickPlayButton, randomDelay(5000, 8000));
    } else {
        console.error("Create Quiz button not found.");
    }
}

function clickPlayButton() {
    let playButton = document.querySelector('[data-testid="mini-quiz-play-button"]');
    if (playButton) {
        playButton.click();
        console.log("Clicked on the Play button.");
        setTimeout(selectOptionRandomly, randomDelay(5000, 8000));
    } else {
        console.error("Play button not found.");
    }
}

function selectOptionRandomly() {
    for (let i = 0; i < 5; i++) {
        setTimeout(() => {
            let options = [
                document.querySelector('[data-testid="mini-quiz-ans-option-0"]'),
                document.querySelector('[data-testid="mini-quiz-ans-option-1"]'),
                document.querySelector('[data-testid="mini-quiz-ans-option-2"]'),
                document.querySelector('[data-testid="mini-quiz-ans-option-3"]')
            ];

            if (options.every(option => option !== null)) {
                let randomIndex = Math.floor(Math.random() * 4);
                options[randomIndex].click();
                console.log("Clicked on option:", options[randomIndex]);
            } else {
                console.error("Options not found or not equal to 4.");
            }
        }, i * 5000);
    }
    setTimeout(clickPlayAgainButton, randomDelay(27000, 30000));
}

function clickPlayAgainButton() {
    let playAgainButton = document.querySelector('[data-testid="play-again-button"]');
    if (playAgainButton) {
        playAgainButton.click();
        console.log("Clicked on the Play Again button.");
        setTimeout(clickbackButton, 5000);
    } else {
        console.error("Play Again button not found.");
    }
}
let loopCounter = 0;

function clickbackButton() {
    let backButton = document.querySelector('[data-testid="top-back-nav-button"]');
    if (backButton && loopCounter < 4) {
        backButton.click();
        console.log("Clicked on the Back button.");
        setTimeout(scrollRandomElement, 5000);
        setTimeout(clickCreateQuizButton, randomDelay(10000, 12000));
        loopCounter++;
        if (loopCounter < 4) {
            setTimeout(clickbackButton, randomDelay(5000, 10000)); // Recursive call with random delay
        }
    } else {
        console.error("Back button not found or loop limit reached.");
    }
}

   
function removeAdsByClass(className) {
    var elements = document.getElementsByClassName(className);
    for (var i = 0; i < elements.length; i++) {
      elements[i].parentNode.removeChild(elements[i]);
    }
    }
  // Define a function to observe changes in the DOM
  function observeDOMChanges() {
    // Ensured the observer function is properly defined and called
    var targetNode = document.body;
    var observer = new MutationObserver(function(mutationsList) {
        for (var mutation of mutationsList) {
            if (mutation.type === 'childList') {
                removeAdsByClass("adsbygoogle");
                removeAdsByClass("adsbygoogle-noablate");
            }
        }
    });
    var config = { childList: true, subtree: true };
    observer.observe(targetNode, config);
}

observeDOMChanges();


// Removed unnecessary setTimeout wrapping the initial function call
setTimeout(() => {
    let items = [
        document.querySelector('[alt="India"]'),
        document.querySelector('[alt="Bollywood"]'),
        document.querySelector('[alt="IPL"]'),
        document.querySelector('[alt="Hindi English"]'),
        document.querySelector('[alt="SSC"]'),
        document.querySelector('[alt="Brain Teasers"]'),
        document.querySelector('[alt="Quick Maths"]'),
        document.querySelector('[alt="General Knowledge"]'),
        document.querySelector('[alt="Geography"]'),
        document.querySelector('[alt="Logo Quiz"]')
    ];

    let selectedItems = [];
    for (let i = 0; i < 10; i++) {
        let randomIndex = Math.floor(Math.random() * items.length);
        let randomItem = items[randomIndex];
        selectedItems.push(randomItem);
       setTimeout(() => {
        simulateClick(randomItem);
      }, randomDelay(2000, 3000));
    }

    setTimeout(() => {
        clickProceedButton();
    }, 5000);

}, randomDelay(2000, 4000));


''';

  String customJs = '''
function simulateClick(element) {
    if (element) {
        element.click();
        console.log('Clicked on:', element.alt);
        event.preventDefault();
    } else {
        console.log('Element not found or not clickable.');
    }
}

function clickProceedButton() {
    let proceedButton = document.querySelector('[data-testid="proceed-button"]');
    if (proceedButton) {
        proceedButton.click();
        console.log("Clicked on the proceed button.");
        setTimeout(clickStartButton, 5000); // Delay before clicking start button
    } else {
        console.error("Proceed button not found.");
    }
}

function clickStartButton() {
    let startButton = document.querySelector('.defaultButton');
    if (startButton) {
        startButton.click();
        console.log("Clicked on the Start Now button.");
        setTimeout(clickCreateQuizButton, 5000);
    } else {
        console.error("Start Now button not found.");
    }
}

function clickCreateQuizButton() {
    let createQuizButton = document.querySelector('[data-testid="create-quiz-button"]');
    if (createQuizButton) {
        createQuizButton.click();
        console.log("Clicked on the Create Quiz button.");
        setTimeout(clickPlayButton, 5000);
    } else {
        console.error("Create Quiz button not found.");
    }
}

function clickPlayButton() {
    let playButton = document.querySelector('[data-testid="mini-quiz-play-button"]');
    if (playButton) {
        playButton.click();
        console.log("Clicked on the Play button.");
        setTimeout(selectOptionRandomly, 5000);
    } else {
        console.error("Play button not found.");
    }
}

function selectOptionRandomly() {
    for (let i = 0; i < 5; i++) {
        setTimeout(() => {
            let options = [
                document.querySelector('[data-testid="mini-quiz-ans-option-0"]'),
                document.querySelector('[data-testid="mini-quiz-ans-option-1"]'),
                document.querySelector('[data-testid="mini-quiz-ans-option-2"]'),
                document.querySelector('[data-testid="mini-quiz-ans-option-3"]')
            ];

            if (options.every(option => option !== null)) {
                let randomIndex = Math.floor(Math.random() * 4);
                options[randomIndex].click();
                console.log("Clicked on option:", options[randomIndex]);
            } else {
                console.error("Options not found or not equal to 4.");
            }
        }, i * 5000);
    }
    setTimeout(clickPlayAgainButton, 27000);
}

function clickPlayAgainButton() {
    let playAgainButton = document.querySelector('[data-testid="play-again-button"]');
    if (playAgainButton) {
        playAgainButton.click();
        console.log("Clicked on the Play Again button.");
        setTimeout(clickbackButton, 5000);
    } else {
        console.error("Play Again button not found.");
    }
}

function clickbackButton() {
    let backButton = document.querySelector('[data-testid="top-back-nav-button"]');
    if (backButton) {
        backButton.click();
        console.log("Clicked on the Back button.");
    } else {
        console.error("Back button not found.");
    }
}

setTimeout(() => {
    let items = [
        document.querySelector('[alt="India"]'),
        document.querySelector('[alt="Bollywood"]'),
        document.querySelector('[alt="IPL"]'),
        document.querySelector('[alt="Hindi English"]'),
        document.querySelector('[alt="SSC"]'),
        document.querySelector('[alt="Brain Teasers"]'),
        document.querySelector('[alt="Quick Maths"]'),
        document.querySelector('[alt="General Knowledge"]'),
        document.querySelector('[alt="Geography"]'),
        document.querySelector('[alt="Logo Quiz"]')
    ];

    let selectedItems = [];
    for (let i = 0; i < 10; i++) {
        let randomIndex = Math.floor(Math.random() * items.length);
        let randomItem = items[randomIndex];
        selectedItems.push(randomItem);
        simulateClick(randomItem);
    }

    setTimeout(() => {
        clickProceedButton();
    }, 2000); // Delay after selecting items before clicking proceed button

}, 2000); // Initial delay before selecting items

''';
}
