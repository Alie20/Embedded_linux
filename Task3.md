<p align = "center">
<h1> Task3 </h1>
</p>


1. **Check how many cores do you have.**
   - write top command then press no.1 

   - There are 16 cores 
   <p align="center">
    <img src="./imgs/cores_no.png" alt="strace for ps">
    </p>



2. **Create number of cores + 2 processes dd if=/dev/zero of=/dev/null run in background.**
   <p align="center">
    <img src="./imgs/task3_dd.png" alt="strace for ls">
    </p>

3. **Change priority for them: -20, -10, 0, .. , 19**


   - tasks before change prioirties
   <p align="center">
    <img src="./imgs/task3_beforechangepriority.png" alt="strace for ls">
    </p>
  
   - Change prioirties
   <p align="center">
    <img src="./imgs/task3_changepriority.png" alt="strace for ls">
    </p>

   - tasks after changing the priorities
   <p align="center">
    <img src="./imgs/task3_afterchangepriority.png" alt="strace for ls">
    </p>

4. **Kill them all using killall command.**
   <p align="center">
    <img src="./imgs/task3_pkill.png" alt="strace for ls">
    </p>
   




