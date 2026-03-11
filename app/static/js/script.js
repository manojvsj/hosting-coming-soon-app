// === Countdown Timer ===
// Set your launch date here (YYYY-MM-DDTHH:MM:SS)
const launchDate = new Date('2026-06-01T00:00:00').getTime();

function updateCountdown() {
  const now = new Date().getTime();
  const distance = launchDate - now;

  if (distance < 0) {
    document.getElementById('countdown').innerHTML =
      '<p style="font-size:1.5rem; color:#4cff88;">🚀 We have launched!</p>';
    return;
  }

  const days    = Math.floor(distance / (1000 * 60 * 60 * 24));
  const hours   = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((distance % (1000 * 60)) / 1000);

  document.getElementById('days').textContent    = String(days).padStart(2, '0');
  document.getElementById('hours').textContent   = String(hours).padStart(2, '0');
  document.getElementById('minutes').textContent = String(minutes).padStart(2, '0');
  document.getElementById('seconds').textContent = String(seconds).padStart(2, '0');
}

updateCountdown();
setInterval(updateCountdown, 1000);

// === Notify Form ===
function handleSubmit(event) {
  event.preventDefault();
  const email = document.getElementById('email').value;
  console.log('Subscriber email:', email);

  // TODO: Replace with real API call (e.g., Firebase, Mailchimp, etc.)
  document.getElementById('success-message').style.display = 'block';
  document.getElementById('email').value = '';
}