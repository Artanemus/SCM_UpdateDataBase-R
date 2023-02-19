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

![ScreenShot of UPDB after logging in.](ASSETS/Screenshot%202022-09-09%20113118.JPG)

---

## SCM UpdateDataBase_64bit_v1.5.1.0.exe 2023/02/23

For users running database SCMSystem values: (1,1,5,0).

> It takes your (1,1,5,0) database and turns it into (1,1,5,1)

Any of these core application versions can run on this database.

- SCM_SwimClubMeet_32bit_v1.5.4.0
- SCM_SwimClubMeet_32bit_v1.5.3.0
- SCM_SwimClubMeet_x32_v1.5.2.0
- SCM_SwimClubMeet_x32_v1.5.1.0

Notes on this update.

- Fixes scalar function. `dbo.IsMemberNominated.UserDefinedFunction.sql`.
- New field: `SwimClubMeet.dbo.Member.IsSwimmer` (BIT).
- Sets DEFAULT on fields `IsArchived`, `IsActive` and `IsSwimmer` in SwimClubMeet.dbo.Member.
- Re-index (changed field orders) in table `dbo.Member`. 
- Repairs default values for fields IsArchived and IsActive on existing records in SwimClubMeet.dbo.Member. (If they read NULL.)
- Updates SCMSystem values to: (1,1,5,1).

Special note:

After the update a temporary table with the name `Member_` followed by a large hash number will appear in the database. After testing, you may remove this table. It's also safe to leave it.

---

## SCM UpdateDataBase_x64_v1.1.0.0.exe 09/09/2022

***Who should use this update?***

>For use ONLY by early adopters of the SCM project.

If you created your database by using SCM_BuildMeAClub_x64_v1.1.0.0 then you ***DON'T*** need this update! 😃.

Notes on this update.

- Takes a very old 1.0.0.0 version and bring it up to date.
- It requires delivery of SQL scripts from the developer!
- Updates SCMSystem values to: (1,1,5,0)

---
