importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyA77Lx9CNyzltzdxPwqP1NUGITVStq0iQs',
  authDomain: 'iconnectv2-49c98.firebaseapp.com',
  projectId: 'iconnectv2-49c98',
  storageBucket: 'iconnectv2-49c98.appspot.com',
  messagingSenderId: '444759864301',
  appId: '1:444759864301:web:ccf8ea02900aaf09c8ade4',
  measurementId: 'G-99YSTD4897',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const title = notification.title || 'Notification';
  const options = {
    body: notification.body || '',
    icon: notification.icon,
  };
  self.registration.showNotification(title, options);
});
