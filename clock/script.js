
    function updateClock() {
        const now = new Date();
        let hours = now.getHours();
        const minutes = now.getMinutes();
        const seconds = now.getSeconds();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        
        // 12-hour format
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'

        // Setting inner text for hours, minutes, and seconds
        document.getElementById("hrs").innerText = String(hours).padStart(2, '0');
        document.getElementById("mins").innerText = String(minutes).padStart(2, '0');
        document.getElementById("secs").innerText = String(seconds).padStart(2, '0');
        document.getElementById("ampm").innerText = ampm;

        // Rotate circles
        const hh = document.getElementById("hh");
        const mm = document.getElementById("mm");
        const ss = document.getElementById("ss");

        hh.style.strokeDashoffset = 440 - (440 * hours) / 12;
        mm.style.strokeDashoffset = 440 - (440 * minutes) / 60;
        ss.style.strokeDashoffset = 440 - (440 * seconds) / 60;

        // Dot rotation
        document.querySelector('.h_dot').style.transform = `rotate(${(hours * 30) + (minutes / 2)}deg)`;
        document.querySelector('.m_dot').style.transform = `rotate(${minutes * 6}deg)`;
        document.querySelector('.s_dot').style.transform = `rotate(${seconds * 6}deg)`;
    }

    setInterval(updateClock, 1000);
