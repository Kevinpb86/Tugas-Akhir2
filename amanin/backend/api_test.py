import urllib.request
import json
import random

BASE_URL = "http://localhost:8000"

def run_tests():
    print("=== STARTING API TESTS ===")
    
    # 1. Test Health Check
    try:
        res = urllib.request.urlopen(f"{BASE_URL}/health")
        health = json.loads(res.read().decode())
        print(f"[OK] Health Check: {health}")
    except Exception as e:
        print(f"[FAIL] Health Check failed: {e}")
        return

    # 2. Generate random test user
    rand_id = random.randint(1000, 9999)
    email = f"test_user_{rand_id}@example.com"
    password = "SecurePassword123!"
    full_name = f"Test User {rand_id}"

    # 3. Test Registration
    try:
        reg_data = json.dumps({
            "full_name": full_name,
            "email": email,
            "password": password
        }).encode("utf-8")
        req = urllib.request.Request(
            f"{BASE_URL}/register", 
            data=reg_data, 
            headers={"Content-Type": "application/json"}
        )
        res = urllib.request.urlopen(req)
        reg_res = json.loads(res.read().decode())
        print(f"[OK] Registration: {reg_res}")
    except Exception as e:
        print(f"[FAIL] Registration failed: {e}")
        return

    # 4. Test Duplicate Registration
    try:
        reg_data = json.dumps({
            "full_name": full_name,
            "email": email,
            "password": password
        }).encode("utf-8")
        req = urllib.request.Request(
            f"{BASE_URL}/register", 
            data=reg_data, 
            headers={"Content-Type": "application/json"}
        )
        urllib.request.urlopen(req)
        print("[FAIL] Duplicate registration should have failed but succeeded.")
    except urllib.error.HTTPError as e:
        print(f"[OK] Duplicate Registration correctly failed with: {e.code} - {e.reason}")

    # 5. Test Login
    try:
        login_data = json.dumps({
            "email": email,
            "password": password
        }).encode("utf-8")
        req = urllib.request.Request(
            f"{BASE_URL}/login", 
            data=login_data, 
            headers={"Content-Type": "application/json"}
        )
        res = urllib.request.urlopen(req)
        login_res = json.loads(res.read().decode())
        print(f"[OK] Login: {login_res}")
    except Exception as e:
        print(f"[FAIL] Login failed: {e}")
        return

    # 6. Test Prediction (BMKG)
    try:
        predict_data = json.dumps({
            "magnitude": 5.8,
            "depth": 15.0,
            "latitude": -6.90,
            "longitude": 107.60,
            "source": "bmkg"
        }).encode("utf-8")
        req = urllib.request.Request(
            f"{BASE_URL}/predict", 
            data=predict_data, 
            headers={"Content-Type": "application/json"}
        )
        res = urllib.request.urlopen(req)
        predict_res = json.loads(res.read().decode())
        print(f"[OK] Prediction (BMKG): {predict_res}")
    except Exception as e:
        print(f"[FAIL] Prediction (BMKG) failed: {e}")
        return

    # 7. Test Prediction (USGS)
    try:
        predict_data = json.dumps({
            "magnitude": 6.2,
            "depth": 80.0,
            "latitude": -7.20,
            "longitude": 108.10,
            "source": "usgs"
        }).encode("utf-8")
        req = urllib.request.Request(
            f"{BASE_URL}/predict", 
            data=predict_data, 
            headers={"Content-Type": "application/json"}
        )
        res = urllib.request.urlopen(req)
        predict_res = json.loads(res.read().decode())
        print(f"[OK] Prediction (USGS): {predict_res}")
    except Exception as e:
        print(f"[FAIL] Prediction (USGS) failed: {e}")
        return

    print("=== ALL TESTS PASSED SUCCESSFULLY ===")

if __name__ == "__main__":
    run_tests()
