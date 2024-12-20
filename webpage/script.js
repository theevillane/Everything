const users = [
    { username: 'admin', password: 'password123', name: 'John Doe' }
];

const routes = {
    '/signup': renderSignup,
    '/login': renderLogin,
    '/dashboard': renderDashboard,
    '/about': renderAboutUs,
    '/contact': renderContact,
    '/reset-password': renderResetPassword
};

function renderApp(content) {
    const app = document.getElementById('app');
    app.innerHTML = `
        <nav class="nav">
            <a href="#/login">Login</a>
            <a href="#/signup">Signup</a>
            <a href="#/dashboard">Dashboard</a>
            <a href="#/about">About Us</a>
            <a href="#/contact">Contact</a>
        </nav>
        ${content}
    `;
}

function updateActiveNav() {
    const links = document.querySelectorAll('.nav a');
    const hash = window.location.hash;
    links.forEach(link => {
        if (link.href.includes(hash)) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
}

function router() {
    const hash = window.location.hash.slice(2) || 'login';
    const route = routes['/' + hash];
    if (route) {
        route();
        updateActiveNav();
    }
}


function renderSignup() {
    renderApp(`
        <div class="container">
            <h2>Sign Up</h2>
            <form id="signupForm">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" id="signupUsername" required>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" id="signupPassword" required>
                </div>
                <div class="form-group">
                    <label>Confirm Password</label>
                    <input type="password" id="confirmPassword" required>
                </div>
                <button type="submit" class="btn">Sign Up</button>
            </form>
        </div>
    `);

    document.getElementById('signupForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const username = document.getElementById('signupUsername').value;
        const password = document.getElementById('signupPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (password !== confirmPassword) {
            alert('Passwords do not match');
            return;
        }

        if (users.some(user => user.username === username)) {
            alert('Username already exists');
            return;
        }

        users.push({ username, password, name: username });
        alert('Signup successful');
        window.location.hash = '/login';
    });
}

function renderLogin() {
    renderApp(`
        <div class="container">
            <h2>Login</h2>
            <form id="loginForm">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" id="loginUsername" required>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" id="loginPassword" required>
                </div>
                <button type="submit" class="btn">Login</button>
            </form>
            <button class="btn reset-btn" onclick="window.location.hash='/reset-password'">Forgot Password?</button>
        </div>
    `);

    document.getElementById('loginForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const username = document.getElementById('loginUsername').value;
        const password = document.getElementById('loginPassword').value;

        const user = users.find(u => u.username === username && u.password === password);
        if (user) {
            localStorage.setItem('currentUser', JSON.stringify(user));
            window.location.hash = '/dashboard';
        } else {
            alert('Invalid username or password');
        }
    });
}


function renderDashboard() {
    const currentUser = JSON.parse(localStorage.getItem('currentUser'));
    if (!currentUser) {
        window.location.hash = '/login';
        return;
    }

    const userData = getUserData(currentUser);

    renderApp(`
        <div class="dashboard-content">
            <div class="dashboard-card">
                <h2>Welcome, ${currentUser.name}!</h2>
                <p>This is your personal dashboard.</p>
            </div>
            <div class="dashboard-card">
                <h3>Tasks</h3>
                <ul id="taskList">
                    ${userData.tasks.map(task => '<li>${task}</li>').join('')}
                </ul>
                <input type="text" id="newTask" placeholder="New Task">
                <button class="btn" onclick="addTask()">Add Task</button>
            </div>
            <button class="btn" onclick="logout()">Logout</button>
        </div>
    `);
}


function renderAboutUs() {
    renderApp(`
        <div class="container">
            <h2>About Us</h2>
            <p>We are a passionate team dedicated to creating simple and effective web applications.</p>
            <div class="dashboard-card">
                <h3>Our Mission</h3>
                <p>To provide user-friendly web solutions that make your digital experience smoother.</p>
            </div>
        </div>
    `);
}

function renderContact() {
    renderApp(`
        <div class="container">
            <h2>Contact Us</h2>
            <form id="contactForm">
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" required>
                </div>
                <div class="form-group">
                    <label>Message</label>
                    <textarea style="width: 100%; padding: 10px; min-height: 100px;"></textarea>
                </div>
                <button type="submit" class="btn">Send Message</button>
            </form>
        </div>
    `);

    document.getElementById('contactForm').addEventListener('submit', function(e) {
        e.preventDefault();
        alert('Message sent successfully!');
    });
}

function renderResetPassword() {
    renderApp(`
        <div class="container">
            <h2>Reset Password</h2>
            <form id="resetPasswordForm">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" id="resetUsername" required>
                </div>
                <div class="form-group">
                    <label>New Password</label>
                    <input type="password" id="newPassword" required>
                </div>
                <div class="form-group">
                    <label>Confirm Password</label>
                    <input type="password" id="confirmNewPassword" required>
                </div>
                <button type="submit" class="btn">Reset Password</button>
            </form>
        </div>
    `);

    document.getElementById('resetPasswordForm').addEventListener('submit', function (e) {
        e.preventDefault();
        const username = document.getElementById('resetUsername').value;
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmNewPassword').value;

        if (newPassword !== confirmPassword) {
            alert('Passwords do not match.');
            return;
        }

        const users = JSON.parse(localStorage.getItem('users')) || [];
        const user = users.find(u => u.username === username);

        if (!user) {
            alert('User not found.');
            return;
        }

        user.password = btoa(newPassword); // Simulating hashing, replace with proper hash in production
        localStorage.setItem('users', JSON.stringify(users));
        alert('Password reset successful. Please login with your new password.');
        window.location.hash = '/login';
    });
}


function addTask() {
    const currentUser = JSON.parse(localStorage.getItem('currentUser'));
    if (!currentUser) return;

    const taskInput = document.getElementById('newTask');
    if (taskInput.value) {
        const taskList = document.getElementById('taskList');
        const li = document.createElement('li');
        li.textContent = taskInput.value;
        taskList.appendChild(li);

        const userData = getUserData(currentUser);
        userData.tasks.push(taskInput.value);
        saveUserData(currentUser, userData);

        taskInput.value = '';
    }
}

function saveUserData(user, data) {
    const allData = JSON.parse(localStorage.getItem('dashboardData')) || {};
    allData[user.username] = data;
    localStorage.setItem('dashboardData', JSON.stringify(allData));
}

function getUserData(user) {
    const allData = JSON.parse(localStorage.getItem('dashboardData')) || {};
    return allData[user.username] || { tasks: [] };
}


function showToast(message) {
    const toast = document.createElement('div');
    toast.className = 'toast show';
    toast.innerText = message;
    document.body.appendChild(toast);
    setTimeout(() => {
        toast.classList.remove('show');
        document.body.removeChild(toast);
    }, 3000);
}


showToast('Signup successful!');


function logout() {
    localStorage.removeItem('currentUser');
    window.location.hash = '/login';
}

function router() {
    const hash = window.location.hash.slice(2) || 'login';
    const route = routes['/' + hash];
    if (route) route();
}

window.addEventListener('hashchange', router);
window.addEventListener('load', router);