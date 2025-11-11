Find `swaks` Path: `cron` requires absolute paths. Find the `swaks` path:

```
which swaks
```

(This will likely output `/usr/bin/swaks`)

Create & Edit Script:

- Create your script file: `nano warmup.sh`
    
- Copy the `warmup.sh` script code into the file.
    
- **Crucially,** edit the last line of the script to use the absolute path you found in Step 2.
    

**Change this:**

```
swaks --server "$SERVER" \
```

**To this (example):**

```
/usr/bin/swaks --server "$SERVER" \
```

Make Executable:

```
chmod +x warmup.sh
```

## 4. Step 2: Manual Test Run

Before automating, run the script once manually to ensure it works.

- **Usage:** `./warmup.sh <server_address> <to_email> <from_email>`
    
- **Example:**
    
    ```
    ./warmup.sh mail.cia-smtp-auth.nl test@example.com jan@cia-smtp-auth.nl
    ```
    
- If successful, you will see the "--- Sending Email ---" output.
    

## 5. Step 3: Automation with `cron`

Create Log Directory: Create a place to store the output logs.

```
mkdir -p $HOME/logs
touch $HOME/logs/warmup.log
```

Edit Crontab: Open your user's `cron` file.

```
crontab -e
```

(Select `nano` as your editor if prompted).

Add Cron Job: Go to the bottom of the file and add one of the following lines.

**Option A (Every 30 Mins):**

```
*/30 * * * * /home/jan/warmup.sh mail.cia-smtp-auth.nl jron21647@gmail.com jan@cia-smtp-auth.nl >> /home/jan/logs/warmup.log 2>&1
```

**Option B (Recommended - Random, Hourly):** This runs once per hour, at a random time within the first 15 minutes, which looks more "natural."

```
0 * * * * sleep $((RANDOM % 900)); /home/jan/warmup.sh mail.cia-smtp-auth.nl jron21647@gmail.com jan@cia-smtp-auth.nl >> /home/jan/logs/warmup.log 2>&1
```

_Note: Replace `/home/jan/` with the full, absolute path to your `warmup.sh` script._

Save and Exit:

- In `nano`, press `Ctrl+O`, `Enter` to save, then `Ctrl+X` to exit.
    
- You should see `crontab: installing new crontab`.
    

## 6. Step 4: Verification

Check Crontab: Verify the job is saved.

```
crontab -l
```

Monitor Log: Watch the log file to see the script's output when it runs next.

```
tail -f $HOME/logs/warmup.log
```

(Press `Ctrl+C` to stop monitoring).
