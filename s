<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>All India Muslim Personal Board</title>
  <style>
    body { font-family: Arial, sans-serif; margin:0; background:#f8f9fa; }
    header { background:#004080; color:white; text-align:center; padding:15px; }
    header h1 { margin:0; font-size:22px; }
    main { max-width:900px; margin:auto; padding:20px; }
    .member-card {
      display:flex; align-items:center;
      background:white; margin:10px 0; padding:10px;
      border-radius:8px; box-shadow:0 2px 5px rgba(0,0,0,0.1);
    }
    .member-card img {
      width:80px; height:80px; border-radius:50%;
      margin-right:15px; object-fit:cover;
    }
    .member-card button {
      margin-left: 5px;
      padding: 5px 8px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      font-size: 0.8rem;
    }
    .edit-btn { background: #ffc107; color: #000; }
    .delete-btn { background: #dc3545; color: #fff; }

    form {
      display:none; background:white; padding:20px;
      border-radius:8px; margin-top:20px;
    }
    form input { width:100%; margin:8px 0; padding:10px; }
    form button {
      background:#004080; color:white; border:none;
      padding:10px; cursor:pointer; border-radius:5px;
    }
    #loginBtn {
      margin:20px auto; display:block; background:#db4437; color:white;
      padding:10px 20px; border:none; border-radius:5px; cursor:pointer;
      font-size:16px;
    }
    #msg { color:red; margin-top:10px; text-align:center; }

    /* 3D Home Button */
    .btn-3d-home {
      background: linear-gradient(90deg,#ff4d4d,#4d94ff);
      color: white;
      font-weight: 700;
      box-shadow: 0 6px 0 rgba(0,0,0,0.25), 0 8px 14px rgba(0,0,0,0.25);
      transition: transform 0.1s ease, box-shadow 0.1s ease;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 8px 16px;
      border-radius: 8px;
      margin-bottom: 15px;
    }
    .btn-3d-home:active {
      transform: translateY(3px);
      box-shadow: 0 3px 0 rgba(0,0,0,0.25);
    }
  </style>
</head>
<body>

<header>
  <h1>All Members List</h1>
</header>

<!-- Home Button -->
<a href="index.html" class="btn-3d-home">🏠 Home</a>

<main>
  <h2>Members List</h2>
  <div id="members"></div>

  <!-- Google Login Button -->
  <button id="loginBtn" onclick="googleLogin()">Login with Google</button>
  <p id="msg"></p>

  <!-- Add Member Form -->
  <form id="memberForm">
    <h3>Add Member</h3>
    <input type="text" id="name" placeholder="Member Name" required>
    <input type="file" id="photoFile" accept="image/*" required>
    <button type="button" onclick="addMember()">Add Member</button>
  </form>
</main>

<!-- Firebase SDK -->
<script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js"></script>

<script>
  // Firebase Config
  const firebaseConfig = {
    apiKey: "AIzaSyDMvkPqFKDjrMaLlBkercBYoLxEs1GEbng",
    authDomain: "all-madrasa.firebaseapp.com",
    databaseURL: "https://all-madrsa-default-rtdb.firebaseio.com",
    projectId: "all-madrsa",
    storageBucket: "all-madrsa.appspot.com",
    messagingSenderId: "619313835874",
    appId: "1:619313835874:web:e387e1297663f11fc2463b"
  };

  const imgbbKey = "d12c2e4a8650157b2b6b9fe85336ea43";

  // Init Firebase
  firebase.initializeApp(firebaseConfig);
  const auth = firebase.auth();
  const db = firebase.firestore();

  const adminEmails = ["zaradigitalseva@gmail.com","secondadmin@gmail.com"];

  const membersContainer = document.getElementById("members");
  const loginBtn = document.getElementById("loginBtn");
  const memberForm = document.getElementById("memberForm");
  const msg = document.getElementById("msg");

  // Load Members
  function loadMembers() {
    db.collection("members").orderBy("name").onSnapshot(snapshot => {
      membersContainer.innerHTML = "";
      snapshot.forEach(doc => {
        let m = doc.data();
        let card = document.createElement("div");
        card.className = "member-card";

        let img = document.createElement("img");
        img.src = m.photo;
        img.alt = m.name;

        let span = document.createElement("span");
        span.textContent = m.name;

        card.appendChild(img);
        card.appendChild(span);

        // Admin buttons
        auth.onAuthStateChanged(user => {
          if (user && adminEmails.includes(user.email)) {
            let editBtn = document.createElement("button");
            editBtn.textContent = "✏️ Edit";
            editBtn.className = "edit-btn";
            editBtn.onclick = () => editMember(doc.id, m.name, m.photo);

            let delBtn = document.createElement("button");
            delBtn.textContent = "🗑 Delete";
            delBtn.className = "delete-btn";
            delBtn.onclick = () => deleteMember(doc.id);

            card.appendChild(editBtn);
            card.appendChild(delBtn);
          }
        });

        membersContainer.appendChild(card);
      });
    });
  }
  loadMembers();

  // Auth state
  auth.onAuthStateChanged(user => {
    if (user) {
      if (adminEmails.includes(user.email)) {
        loginBtn.style.display = "none";
        memberForm.style.display = "block";
        msg.innerText = "";
      } else {
        loginBtn.style.display = "none";
        memberForm.style.display = "none";
        msg.innerText = "aap bhi jude aaj hi aur abhi";
      }
    } else {
      loginBtn.style.display = "block";
      memberForm.style.display = "none";
      msg.innerText = "";
    }
  });

  // Google Login
  function googleLogin() {
    const provider = new firebase.auth.GoogleAuthProvider();
    auth.signInWithPopup(provider).catch(err => alert("Login Failed: "+err.message));
  }

  // Upload image to imgbb
  async function uploadImage(file) {
    let formData = new FormData();
    formData.append("image", file);
    let res = await fetch(`https://api.imgbb.com/1/upload?key=${imgbbKey}`, {
      method: "POST",
      body: formData
    });
    let data = await res.json();
    return data.data.url;
  }

  // Add Member
  async function addMember() {
    let name = document.getElementById("name").value;
    let file = document.getElementById("photoFile").files[0];
    if(!file){ alert("कृपया फोटो चुनें"); return; }
    let photoUrl = await uploadImage(file);
    db.collection("members").add({name, photo: photoUrl})
      .then(()=> document.getElementById("memberForm").reset())
      .catch(err=>alert("Error: "+err.message));
  }

  // Edit Member
  function editMember(id, oldName, oldPhoto){
    let newName = prompt("Update Name:", oldName);
    if(!newName) return;
    db.collection("members").doc(id).update({name: newName})
      .then(()=>alert("✅ Name updated!"))
      .catch(err=>alert("Error: "+err.message));
  }

  // Delete Member
  function deleteMember(id){
    if(confirm("Are you sure you want to delete this member?")){
      db.collection("members").doc(id).delete()
        .then(()=>alert("✅ Member deleted!"))
        .catch(err=>alert("Error: "+err.message));
    }
  }
</script>
  <script type="module" src="auth-protect.js"></script>
<!-- Fixed Donate Button -->
<a href="https://all-madrsa.netlify.app/upi" 
   class="fixed top-1/2 right-4 transform -translate-y-1/2 
          bg-yellow-400 text-black font-bold px-5 py-3 
          rounded-lg shadow-lg hover:bg-yellow-300 z-50">
   💝 Donate
</a>
</body>
</html>
