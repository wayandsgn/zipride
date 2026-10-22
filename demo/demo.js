const frame = document.getElementById('app-frame');
const feedback = document.getElementById('feedback');
let feedbackTimer;

function announce(message) {
  clearTimeout(feedbackTimer);
  feedback.textContent = message;
  feedback.classList.add('visible');
  feedbackTimer = setTimeout(() => feedback.classList.remove('visible'), 3500);
}

document.getElementById('reset').addEventListener('click', () => {
  frame.src = new URL('app/', document.baseURI).href;
  announce('Demonstração reiniciada. Vamos para uma nova corrida.');
});

document.getElementById('start').addEventListener('click', () => {
  document.getElementById('experience').focus({ preventScroll: true });
});

const dialog = document.getElementById('share-dialog');
document.getElementById('share').addEventListener('click', async () => {
  const url = new URL(location.href);
  url.hash = '';
  try {
    await navigator.clipboard.writeText(url.href);
    announce('Link copiado. Pronto para compartilhar.');
  } catch {
    const input = document.getElementById('share-url');
    input.value = url.href;
    dialog.showModal();
    input.focus();
    input.select();
  }
});
document.getElementById('close-share').addEventListener('click', () => dialog.close());
