// auth-protect.js
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
import { getAuth, onAuthStateChanged, GoogleAuthProvider, signInWithPopup, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";

const firebaseConfig = {
  apiKey: "AIzaSyDMvkPqFKDjrMaLlBkercBYoLxEs1GEbng",
  authDomain: "all-madrsa.firebaseapp.com",
  projectId: "all-madrsa",
  storageBucket: "all-madrsa.appspot.com",
  messagingSenderId: "619313835874",
  appId: "1:619313835874:web:e387e1297663f11fc2463b"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const provider = new GoogleAuthProvider();

// ✅ login button handle
window.loginWithGoogle = async function () {
  try {
    await signInWithPopup(auth, provider);
  } catch (e) {
    alert("Login failed: " + e.message);
  }
};

// ✅ logout button handle
window.logoutUser = async function () {
  try {
    await signOut(auth);
  } catch (e) {
    alert("Logout failed: " + e.message);
  }
};

// ✅ auto check login on each page
onAuthStateChanged(auth, (user) => {
  if (!user) {
    // अगर login नहीं है → redirect to login page
    if (!location.pathname.endsWith("login.html")) {
      window.location.href = "login.html";
    }
  } else {
    console.log("Logged in as:", user.email);
  }
});
