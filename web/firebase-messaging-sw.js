// web/firebase-messaging-sw.js
// Firebase Cloud Messaging service worker for background push on Chrome/web.
// This file must be at the web root (not inside a subdirectory).

importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

// Firebase config must match firebase_options.dart (web config).
firebase.initializeApp({
  apiKey:            'AIzaSyBlHm5WB03hybKHp72rqyGHpA88K5UBzaw',
  authDomain:        'auction-netherlands.firebaseapp.com',
  projectId:         'auction-netherlands',
  storageBucket:     'auction-netherlands.firebasestorage.app',
  messagingSenderId: '239803553427',
  appId:             '1:239803553427:web:8372d544c1cefbf364df66',
  measurementId:     'G-450SELDKL9',
});

const messaging = firebase.messaging();

// Handle background messages (app in background or closed tab).
messaging.onBackgroundMessage((payload) => {
  console.log('[SW] Background message received:', payload);

  const notification = payload.notification ?? {};
  const title        = notification.title ?? 'Vakantieveilingen';
  const body         = notification.body  ?? '';
  const icon         = notification.icon  ?? '/icons/Icon-192.png';

  self.registration.showNotification(title, {
    body,
    icon,
    badge: '/icons/Icon-192.png',
    data:  payload.data ?? {},
    actions: [],
  });
});

// Open or focus the app when notification is clicked.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const data      = event.notification.data ?? {};
  const type      = data.type ?? '';
  const auctionId = data.auctionId ?? data.id ?? '';

  let path = '/admin/dashboard';
  if (type === 'auction' && auctionId) path = `/auction/${auctionId}`;
  if (type === 'order')                path = `/my-auctions`;

  const url = self.location.origin + path;

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url === url && 'focus' in client) {
          return client.focus();
        }
      }
      return clients.openWindow(url);
    })
  );
});
