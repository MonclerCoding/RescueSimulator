# Rescue Simulator

Pierwszy grywalny prototyp Roblox Rescue Simulator przygotowany pod Rojo.

## Repo i folder

- GitHub: `MonclerCoding/RescueSimulator`
- Windows: `E:\RobloxGame\RescueSimulator`
- Rojo: `127.0.0.1:34872`

## Co jest w prototypie

- generowana testowa wyspa,
- małe jezioro i spawn,
- NPC Manager Wysp,
- wieża ratownika i system ulepszania,
- HUD z Money i Level,
- menu Maps / Tower / Pets / Shop / Admin,
- szybki teleport na Starter Island,
- panel map z mapami zablokowanymi pod kolejne levele,
- Rescue Dog, Lifeguard Duck i Rescue Turtle,
- podstawowy wizualny pet podążający za graczem,
- sklep z Rescue Buoy, Rescue Vest, Binoculars, Sun Cream i Megaphone,
- panel admina z Add Money,
- serwerowa walidacja zakupów, admina, teleportów i ulepszania wieży.

## Start developmentu

Uruchom:

`START_RESCUE_DEV.bat`

Skrypt:

1. bezpiecznie sprawdza nowe commity na GitHub,
2. uruchamia AutoPull co 15 sekund,
3. uruchamia `rojo serve`,
4. trzyma Rojo pod `127.0.0.1:34872`.

W Roblox Studio:

1. otwórz miejsce / Baseplate,
2. `Plugins -> Rojo`,
3. połącz z `127.0.0.1:34872`,
4. wykonaj synchronizację,
5. kliknij `Play`.

GUI jest tworzone przez LocalScript i pojawia się podczas `Play`.

## Synchronizacja

`SYNC_NOW.bat` — natychmiast GitHub -> PC.

`PUSH_LOCAL.bat` — lokalne zmiany PC -> GitHub.

AutoPull celowo nie używa `git reset --hard`. Jeśli wykryje lokalne zmiany, nie nadpisuje ich.

## Admin

W Roblox Studio administrator jest włączony do testów przez `Config.AllowStudioAdmin = true`.

Przed publikacją dodaj Roblox UserId administratora w `src/shared/Config.luau`.

## Dane

Aktualna wersja jest prototypem. Dane gracza są sesyjne. Następny etap może dodać trwały zapis DataStore/ProfileStore.


## Diagnostyka

`STATUS.bat` pokazuje stan Git, GitHub i Rojo.
