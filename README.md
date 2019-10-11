# Key-value HTTP storage based on Tarantool DB

Key-value storage for Tarantool NoSQL database with HTTP API

## Requirements
* tarantool >=1.10 ```https://tarantool.io```<br />
    * Installation of Tarantool for Ubuntu:
```shell
# install these utilities if they are missing
apt-get -y install sudo
sudo apt-get -y install gnupg2
sudo apt-get -y install curl

curl http://download.tarantool.org/tarantool/1.10/gpgkey | sudo apt-key add -

# install the lsb-release utility and use it to identify the current OS code name;
# alternatively, you can set the OS code name manually, e.g. xenial or bionic
sudo apt-get -y install lsb-release
release=`lsb_release -c -s`

# install https download transport for APT
sudo apt-get -y install apt-transport-https

# append two lines to a list of source repositories
sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
echo "deb http://download.tarantool.org/tarantool/1.10/ubuntu/ ${release} main" | sudo tee /etc/apt/sources.list.d/tarantool_1_10.list
echo "deb-src http://download.tarantool.org/tarantool/1.10/ubuntu/ ${release} main" | sudo tee -a /etc/apt/sources.list.d/tarantool_1_10.list

# install tarantool
sudo apt-get -y update
sudo apt-get -y install tarantool
```
## Dependencies
* HTTP server for Tarantool 1.7.5+
https://github.com/tarantool/http

## Installing this script
```shell
git clone ...
tarantoolctl rocks install http
```

## Run script
```shell
tarantool kv.lua <host> <port>
```

* Example
```shell
tarantool kv.lua 127.0.0.1 8080
```

### API
**Get value for existing key**

* **URL**

  /kv/{id}
  
* **Method:**

  `GET`
  
*  **URL Params**

   **Required:**
 
   `id=[string]`

* **Data Params**

  None

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{SOME ARBITRARY JSON}`
 
* **Error Response:**

  * **Code:** 404<br />
    **Content:** `No such key`
<br>

**Create new key-value item**

* **URL**

  /kv

* **Method:**

  `POST`
  
* **URL Params**

  None

* **Data Params**

  `{"key": "KEY_NAME", "value": {SOME ARBITRARY JSON}}`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{"key": "KEY_NAME", "value": {SOME ARBITRARY JSON}}`
 
* **Error Response:**

  * **Code:** 400<br />
    **Content:** `Invalid request body`
    
    OR

  * **Code:** 409<br />
    **Content:** `Key already exists`
    
    OR

  * **Code:** 429<br />
    **Content:** `Too Many Requests`<br />
    *Note:* RPS limit = 2.
    
    


<br>

**Edit value for existing key**

* **URL**

  /kv/{id}

* **Method:**

  `PUT`
  
*  **URL Params**

   **Required:**
 
   `id=[string]`

* **Data Params**

  `{"value": {SOME ARBITRARY JSON}}`

* **Success Response:**

  * **Code:** 204 <br />
 
* **Error Response:**

  * **Code:** 400<br />
    **Content:** `Invalid request body`
   
   OR

  * **Code:** 404<br />
    **Content:** `No such key` 
<br>

**Delete existing key**

* **URL**

  /kv/{id}

* **Method:**

  `DELETE`
  
*  **URL Params**

   **Required:**
 
   `id=[string]`

* **Data Params**

  None

* **Success Response:**

  * **Code:** 204 <br />
 
* **Error Response:**
    
  * **Code:** 404<br />
    **Content:** `No such key`



## Examples of JSON:

* **POST:**

    **Content:** `{
  "body":
  {
   "key": "test2",
    "value":
    {
      "DDDDD": "2dd2222",
      "AAAAA": "wwwweee",
      "VVVV": 0.0,
      "GGGGG": 66
    }
  }
}`

* **PUT:**

    **Content:** `{
  "body":
  {
    "value":
    {
      "DDDDD": "2dd2222",
      "AAAAA": "wwwweee",
      "VVVV": 0.0,
      "GGGGG": 66
    }
  }
}`    