# SCM_UpdateDataBase-RELEASE

![Hero UpdateDataBase ICON](ASSETS/SCM_Icons_AutoBuild.png)

### SCM_UpdateDataBase.exe (UPDB) is an application that modifies the SwimClubMeet database in MS SQLEXPRESS to version-up.

---
UPDB is a 64bit application written in pascal. It's part of an eco system of applications that make up the SwimClubMeet project. SCM lets amateur swimming clubs manage members and run their club night's.

![The eco system of SCM](ASSETS/SCM_GroupOfIcons.png)

To learn more about SCM view the [github pages](https://artanemus.github.io/index.html).

If you are interested in following a developer's blog and track my progress then you can find me at [ko-fi](https://ko-fi.com/artanemus).

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/V7V7EU686)

---

### USING SCM_UpdateDataBase

After install, (by default) an icon isn't placed on the desktop. This is a service application and has no excuse to clutter up your desktop. Type **updateD** in the windows search bar to discover it. Else navigate to the **Artanemus** folder on the start bar. (All SCM applications and utilities are located in this folder.)

### ON START-UP

>**ALWAYS** make a backup of your database before running this utility!

The `Update DataBase` button will not be visible until a connection to the database server has been established. UPDB requires the SQL command utility, sqlcmd.exe. If you are using this application to update the database on a remote database server, then sqlcmd.exe must be correctly pathed.

After clicking the UpdateDataBase button you are prompted to confirm. Press `Yes`.

### ERRORS?

The application's memo-pad displays progress and any errors. Additionally, check the log file for MS SQLEXPRESS errors. This can be found at `%USERPROFILE%\Documents\SCM_UpdateDataBase.log`.

---

![ScreenShot of UPDB after logging in.](ASSETS/Screenshot%202024-03-10%20105909.JPG)


