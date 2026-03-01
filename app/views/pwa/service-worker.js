// 보듬(Bodeum) Service Worker — 오프라인 캐싱 + PWA 지원
const CACHE_NAME = 'bodeum-v1';
const OFFLINE_URL = '/offline.html';

// 앱 셸 캐싱 — 핵심 자산 캐시
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll([
                '/',
                '/icon.png'
            ]);
        })
    );
    self.skipWaiting();
});

// 캐시 정리
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames
                    .filter((name) => name !== CACHE_NAME)
                    .map((name) => caches.delete(name))
            );
        })
    );
    self.clients.claim();
});

// 네트워크 우선, 오프라인 시 캐시 사용
self.addEventListener('fetch', (event) => {
    // navigate 요청만 캐시 처리
    if (event.request.mode === 'navigate') {
        event.respondWith(
            fetch(event.request).catch(() => {
                return caches.match('/');
            })
        );
    }
});
