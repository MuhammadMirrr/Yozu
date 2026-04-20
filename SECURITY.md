# Security Policy

## Qoʻllab-quvvatlanadigan versiyalar

Joriy `main` branch va so'nggi release xavfsizlik yangilanishlarini oladi.

| Versiya | Qoʻllab-quvvatlash |
| ------- | ------------------ |
| 1.0.x   | ✅ Qoʻllab-quvvatlanadi |
| < 1.0   | ❌ Qoʻllab-quvvatlanmaydi |

## Zaiflikni xabar qilish

Agar Yozu'da xavfsizlik zaifligi topsangiz, iltimos uni **ochiq GitHub Issue'da yozmang**.

Oʻrniga:

1. **Email yuboring**: `muhammadmirqobilov@gmail.com`
2. Sarlavhada: `[SECURITY] Yozu — <qisqa tavsif>`
3. Xabarga quyidagilarni qoʻshing:
   - Zaiflikning batafsil tavsifi
   - Takrorlash qadamlari (Proof of Concept)
   - Potentsial taʼsir
   - (Ixtiyoriy) taklif qilingan yechim

## Javob muddati

- **Dastlabki javob**: 72 soat ichida
- **Baholash**: 7 kun ichida
- **Fix / chiqarish**: jiddiylikka qarab 30 kun ichida

## Javob jarayoni

1. Xabaringizni olganimizni tasdiqlaymiz.
2. Zaiflikni tekshiramiz va tasdiqlaymiz.
3. Fix tayyorlaymiz va xususiy ravishda test qilamiz.
4. Yangi versiyani chiqaramiz va xabarnoma eʼlon qilamiz.
5. (Rozligingiz bilan) muallif sifatida kreditingizni tan olamiz.

## Doirada boʻlmagan masalalar

Quyidagilar xavfsizlik zaifligi deb hisoblanmaydi:

- AdMob unit/app ID lar — ular binary'da baribir koʻrinadi (public ma'lumot)
- Test AdMob ID lar (`ca-app-pub-3940256099942544/...`) — Google tomonidan rasmiy test ID lar
- Ilovaga Android APK reverse-engineering orqali osonlashtirilgan hujumlar (client-side crypto xavfsizlik chegarasi emas)

Rahmat xavfsiz foydalanish uchun mas'uliyatli yondashuvingizga!
