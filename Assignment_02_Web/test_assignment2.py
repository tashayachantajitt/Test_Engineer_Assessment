import pytest
import re
from playwright.sync_api import Page, expect

BASE_URL = "http://the-internet.herokuapp.com/login"

# 1. Login success
def test_login_success(page: Page):
    #Step 1. Login page is shown. 
    page.goto(BASE_URL)
    page.locator("#username").fill("tomsmith")
    page.locator("#password").fill("SuperSecretPassword!")
    page.get_by_role("button", name="Login").click()
    
    #Step 2. Login success and message 'You logged into a secure area!' is shown.  
    expect(page.locator("#flash")).to_contain_text("You logged into a secure area!")
    
    #Click the 'Logout' button
    #page.get_by_role("link", name="Logout").click()
    #page.click("a[href='/logout']")
    #page.click("text=Logout")
    page.get_by_role("link", name=re.compile("Logout", re.IGNORECASE)).click()
    
    #Step 3. Go back to the Login page and the message ' You logged out of the secure area!' is shown. 
    expect(page).to_have_url(BASE_URL)
    expect(page.locator("#flash")).to_contain_text("You logged out of the secure area!")

#2. Login failed -  Password incorrect 
def test_login_failed_password_incorrect(page: Page):
    #Step 1. Login page is shown. 
    page.goto(BASE_URL)
    page.locator("#username").fill("tomsmith")
    page.locator("#password").fill("Password!")
    page.get_by_role("button", name="Login").click()

    #Step 2. Login failed and the message 'Your password is invalid!' is shown.
    expect(page.locator("#flash")).to_contain_text("Your password is invalid!")

# 3. Login failed - Username not found
def test_login_failed_username_not_found(page: Page):
    #Step 1. Login page is shown. 
    page.goto(BASE_URL)
    page.locator("#username").fill("tomholland") # ชื่อไม่มีในระบบตามโจทย์
    page.locator("#password").fill("Password!")
    page.get_by_role("button", name="Login").click()

    
    #Step 2. Login failed and the message 'Your username is invalid!' is shown. 
    expect(page.locator("#flash")).to_contain_text("Your username is invalid!")