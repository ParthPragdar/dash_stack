String errorJs = '''
  
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
