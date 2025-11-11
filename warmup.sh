#!/bin/bash

# ---
# Domain Warmup Script (v2)
#
# This script has a 50/50 chance to send an email.
# If it decides to send, it waits 4-26 minutes before sending
# a randomly selected and populated email template.
#
# Usage:
# ./warmup-v2.sh <server_address> <to_email> <from_email>
#
# Example:
# ./warmup-v2.sh mail.cia-smtp-auth.nl test-recipient@gmail.com jan@cia-smtp-auth.nl
# ---

# --- 1. Argument Validation ---
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <server_address> <to_email> <from_email>"
    echo "Example: $0 cia-smtp-auth.nl test@example.com sender@my-domain.com"
    exit 1
fi

SERVER="$1"
TO_EMAIL="$2"
FROM_EMAIL="$3"

# --- 2. Random Data Pools ---
# (Add as many items as you want to these lists)

CLIENT_NAMES=("Sarah" "Mark" "David" "Jen" "Alex" "Chris" "Michael" "Emily" "Laura" "James")
COLLEAGUE_NAMES=("Tom" "Priya" "Kevin" "Li" "Marcus")
PROJECT_NAMES=("Q4 Portal Rollout" "New Platform Migration" "Customer Data Analysis" "Onboarding Flow Revamp" "Security Audit")
TASKS=("finalize the customer workflow" "draft the migration plan" "review the segmentation analysis" "wireframe the new homepage" "audit the access logs")
DATA_NEEDED=("the Q3 sales figures" "the latest user-access logs" "the API documentation for the payment gateway" "last month's support tickets")
VENDORS=("Vendor Bender" "Platform Sender" "Vendor Gender" "Platform Bender")
FEATURES=("Future Goal" "scalability" "multi-tenancy" "advanced reporting")
ANALYSIS_TOPICS=("user onboarding flow" "Q3 marketing performance" "support ticket trends" "application performance logs")
ISSUES=("a significant drop-off at the 'profile creation' step" "an unexpected spike in API errors" "low conversion on the new landing page")
WORKSHOPS=("Requirements Gathering Workshop" "Project Kick-off" "Sprint Planning" "Stakeholder Review")

# --- 3. Helper Functions for Random Data ---

# Get a random item from any array passed as an argument
get_random_item() {
    local arr=("$@")
    local count=${#arr[@]}
    local index=$((RANDOM % count))
    echo "${arr[$index]}"
}

# Get a random future date (e.g., "next Friday", "in 3 days")
get_random_date() {
    local days=$((RANDOM % 7 + 2)) # 2-8 days in the future
    # Use GNU date format. Change as needed for BSD/macOS.
    date -d "+${days} days" +"%A, %B %d"
}

# --- 4. Email Template Functions ---
# (Each function echoes its subject line first, then the body)

template_1() {
    local client_name=$(get_random_item "${CLIENT_NAMES[@]}")
    local main_task=$(get_random_item "${TASKS[@]}")
    local my_action=$(get_random_item "${TASKS[@]}")
    local future_date=$(get_random_date)

    echo "Quick follow-up from our call today" # This is the Subject
    echo "Hi $client_name,

Great connecting with you and the team earlier.

Just to make sure we're on the same page, my main takeaway was that
our top priority for this phase is to $main_task.

Based on that, my next step is to $my_action. I'll plan to have
that ready for your review by $future_date.

Does that align with your understanding? Let me know if I missed anything.

Best,

Jan"
}

template_2() {
    local client_name=$(get_random_item "${CLIENT_NAMES[@]}")
    local my_task=$(get_random_item "${PROJECT_NAMES[@]}")
    local needed_data=$(get_random_item "${DATA_NEEDED[@]}")

    echo "Quick question on the $my_task" # Subject
    echo "Hi $client_name,

Hope your week is going well.

I'm making good progress on the $my_task, and I'm on track to
have the first draft ready for you as planned.

I've just run into a small snag—to finish the analysis, I'm missing
the $needed_data.

When you have a moment, could you either send that over or just
point me to the right person to get it from?

Thanks,

Jan"
}

template_3() {
    local client_name=$(get_random_item "${CLIENT_NAMES[@]}")
    local project_feature=$(get_random_item "${PROJECT_NAMES[@]}")
    local vendor_a=$(get_random_item "${VENDORS[@]}")
    local vendor_b=$(get_random_item "${VENDORS[@]}")
    local future_goal=$(get_random_item "${FEATURES[@]}")

    echo "Update on $project_feature - Decision Needed" # Subject
    echo "Hi $client_name,

Just a quick update: I've finished the review of the $project_feature
we discussed. I've narrowed it down to two strong choices.

Here's the quick summary:

1. Option A ($vendor_a): This is the faster, more cost-effective choice.
It meets all our core needs but is less flexible for $future_goal.

2. Option B ($vendor_b): This one is a bit more complex to integrate,
but it's far more scalable and would easily support $future_goal.

I'm leaning slightly toward Option B for the long-term value.

Let me know which direction you'd prefer, and I'll get started on
the implementation plan.

Best,

Jan"
}

template_4() {
    local client_name=$(get_random_item "${CLIENT_NAMES[@]}")
    local analysis_name=$(get_random_item "${ANALYSIS_TOPICS[@]}")
    local specific_issue=$(get_random_item "${ISSUES[@]}")

    echo "Initial findings from the $analysis_name" # Subject
    echo "Hi $client_name,

I've just wrapped up my analysis of the $analysis_name, and the
data is showing some really interesting patterns.

The main takeaway is that we're seeing $specific_issue. I have
a few clear ideas on why this is happening and how we can fix it.

Rather than putting it all in a long email, it would be much better
to show you what I've found. Do you have 30 minutes free sometime
early next week to walk through it together?

Let me know what time works for you.

Best regards,

Jan"
}

template_5() {
    local client_name=$(get_random_item "${CLIENT_NAMES[@]}")
    local project_name=$(get_random_item "${PROJECT_NAMES[@]}")
    local workshop_name=$(get_random_item "${WORKSHOPS[@]}")
    local colleague_1=$(get_random_item "${COLLEAGUE_NAMES[@]}")
    local colleague_2=$(get_random_item "${COLLEAGUE_NAMES[@]}")

    echo "Scheduling the $project_name Kick-off Workshop" # Subject
    echo "Hi $client_name,

Now that we have the initial stakeholder feedback, the next logical
step is to get the core team together for the $workshop_name.

Based on our last chat, we'll need about 90 minutes. The key
people to have in the room would be you, $colleague_1, and $colleague_2.

My goal for this session is to come out with a firm, prioritized
list of 'must-haves' for the first release.

Could you let me know what day and time works best for the three
of you, either late next week or the week after? I'll get it
on the calendar.

Thanks,

Jan"
}

# --- 5. Main Execution (Updated Logic) ---

# 1. 50/50 Chance to Send
# We check if a random number (0 or 1) is equal to 0.
if [ $((RANDOM % 2)) -eq 0 ]; then
    echo "--- 50/50 chance: SKIPPING send. ---"
    exit 0
fi

echo "--- 50/50 chance: PASSED. Will send email. ---"

# 2. Random Delay (4 to 26 minutes)
MIN_DELAY_SEC=$((4 * 60))   # 240 seconds
MAX_DELAY_SEC=$((26 * 60))  # 1560 seconds
# Calculate the range of seconds (1560 - 240 + 1)
RANGE_SEC=$((MAX_DELAY_SEC - MIN_DELAY_SEC + 1))
# Get a random number within the range and add the minimum
DELAY_SEC=$((RANDOM % RANGE_SEC + MIN_DELAY_SEC))
DELAY_MIN=$((DELAY_SEC / 60))

echo "--- Waiting for ${DELAY_SEC}s (approx. ${DELAY_MIN} min) before sending... ---"
# Sleep for the calculated duration
sleep $DELAY_SEC

echo "--- Wait complete. Proceeding to send. ---"

# 3. Pick a random template number from 1 to 5
TEMPLATE_NUM=$((RANDOM % 5 + 1))

# Call the chosen template function
# The function's output (Subject and Body) is captured
TEMPLATE_OUTPUT=$(template_${TEMPLATE_NUM})

# Extract the Subject (the first line)
SUBJECT=$(echo "$TEMPLATE_OUTPUT" | head -n 1)

# Extract the Body (everything *but* the first line)
BODY=$(echo "$TEMPLATE_OUTPUT" | tail -n +2)

echo "--- Sending Email ---"
echo "Server: $SERVER"
echo "To: $TO_EMAIL"
echo "From: $FROM_EMAIL"
echo "Template: #$TEMPLATE_NUM"
echo "Subject: $SUBJECT"
echo "---------------------"
echo "$BODY"
echo "---------------------"

# 4. Execute the swaks command
# Note: Ensure you update this to the *absolute path*
# (e.g., /usr/bin/swaks) when running with cron.
swaks --server "$SERVER" \
      --to "$TO_EMAIL" \
      --from "$FROM_EMAIL" \
      --server 127.0.0.1 \
      --header "Subject: $SUBJECT" \
      --body "$BODY"

echo "--- Done ---"
