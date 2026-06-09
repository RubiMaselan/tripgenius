# \# TripGenius ✈️

# 

# An AI-Powered Itinerary Generator \& Travel Optimizer built with Flutter and PHP.

# 

# \## Features

# 

# \- 🤖 AI-generated travel itineraries powered by Google Gemini

# \- 🔐 User authentication with JWT

# \- 🗺️ Destination search and exploration

# \- 📅 Day-by-day trip planning (Morning / Afternoon / Evening)

# \- 💰 Budget planning and expense tracking

# \- 🏨 Accommodation suggestions

# \- 🚌 Transportation information

# \- ❤️ Wishlist / Favorites

# \- 💾 Save and manage trips

# \- 👤 User profile management

# 

# \## Tech Stack

# 

# | Layer | Technology |

# |---|---|

# | Frontend | Flutter (iOS \& Android) |

# | Backend | PHP (Pure / Custom REST API) |

# | Database | MySQL |

# | AI | Google Gemini 2.0 Flash |

# | Auth | JWT (JSON Web Tokens) |

# 

# \## Project Structure

# tripgenius/

# ├── lib/

# │   ├── main.dart

# │   ├── models/

# │   │   ├── itinerary.dart

# │   │   ├── trip\_input.dart

# │   │   └── user.dart

# │   ├── screens/

# │   │   ├── login\_screen.dart

# │   │   ├── register\_screen.dart

# │   │   ├── trip\_builder\_screen.dart

# │   │   ├── itinerary\_screen.dart

# │   │   ├── saved\_trips\_screen.dart

# │   │   ├── search\_screen.dart

# │   │   ├── destination\_detail\_screen.dart

# │   │   ├── wishlist\_screen.dart

# │   │   ├── profile\_screen.dart

# │   │   └── budget\_screen.dart

# │   └── services/

# │       ├── api\_service.dart

# │       ├── auth\_service.dart

# │       └── storage\_service.dart

# └── backend/

# ├── auth.php

# ├── generate.php

# ├── trips.php

# ├── destinations.php

# ├── wishlist.php

# ├── budget.php

# └── transport.php

# 

# \## Getting Started

# 

# \### Prerequisites

# 

# \- Flutter SDK 3.0+

# \- PHP 8.0+

# \- MySQL 5.7+

# \- Laragon or XAMPP

# \- Google Gemini API Key

# 

# \### Backend Setup

# 

# 1\. Install \[Laragon](https://laragon.org/) or \[XAMPP](https://www.apachefriends.org/)

# 2\. Copy the `backend/` folder to your web server root:

# &#x20;  - Laragon: `C:\\laragon\\www\\tripgenius\\`

# &#x20;  - XAMPP: `C:\\xampp\\htdocs\\tripgenius\\`

# 3\. Create `config.php` from the template:

# 

# ```php

# <?php

# define('GEMINI\_API\_KEY', 'your\_gemini\_api\_key\_here');

# define('GEMINI\_URL', 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent');

# define('JWT\_SECRET', 'your\_jwt\_secret\_here');

# define('DB\_HOST', 'localhost');

# define('DB\_USER', 'root');

# define('DB\_PASS', '');

# define('DB\_NAME', 'tripgenius');

# ```

# 

# 4\. Import the database schema:

# 

# ```sql

# CREATE DATABASE tripgenius;

# USE tripgenius;

# 

# CREATE TABLE users (

# &#x20; id INT AUTO\_INCREMENT PRIMARY KEY,

# &#x20; name VARCHAR(100) NOT NULL,

# &#x20; email VARCHAR(150) UNIQUE NOT NULL,

# &#x20; password VARCHAR(255) NOT NULL,

# &#x20; created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP

# );

# 

# CREATE TABLE trips (

# &#x20; id VARCHAR(100) PRIMARY KEY,

# &#x20; user\_id INT NOT NULL,

# &#x20; destination VARCHAR(150) NOT NULL,

# &#x20; days INT NOT NULL,

# &#x20; interests TEXT,

# &#x20; budget VARCHAR(20),

# &#x20; plan LONGTEXT NOT NULL,

# &#x20; created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

# &#x20; FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE

# );

# 

# CREATE TABLE destinations (

# &#x20; id INT AUTO\_INCREMENT PRIMARY KEY,

# &#x20; name VARCHAR(150) NOT NULL,

# &#x20; country VARCHAR(100),

# &#x20; description TEXT,

# &#x20; image\_url VARCHAR(255),

# &#x20; category VARCHAR(50)

# );

# 

# CREATE TABLE attractions (

# &#x20; id INT AUTO\_INCREMENT PRIMARY KEY,

# &#x20; destination\_id INT NOT NULL,

# &#x20; name VARCHAR(150) NOT NULL,

# &#x20; description TEXT,

# &#x20; category VARCHAR(50),

# &#x20; FOREIGN KEY (destination\_id) REFERENCES destinations(id)

# );

# 

# CREATE TABLE accommodation (

# &#x20; id INT AUTO\_INCREMENT PRIMARY KEY,

# &#x20; destination\_id INT NOT NULL,

# &#x20; name VARCHAR(150) NOT NULL,

# &#x20; type VARCHAR(50),

# &#x20; price\_range VARCHAR(50),

# &#x20; description TEXT,

# &#x20; FOREIGN KEY (destination\_id) REFERENCES destinations(id)

# );

# 

# CREATE TABLE transport (

# &#x20; id INT AUTO\_INCREMENT PRIMARY KEY,

# &#x20; from\_destination VARCHAR(150) NOT NULL,

# &#x20; to\_destination VARCHAR(150) NOT NULL,

# &#x20; mode VARCHAR(50),

# &#x20; duration VARCHAR(50),

# &#x20; price\_range VARCHAR(50),

# &#x20; description TEXT

# );

# 

# CREATE TABLE budgets (

# &#x20; id INT AUTO\_INCREMENT PRIMARY KEY,

# &#x20; trip\_id VARCHAR(100) NOT NULL,

# &#x20; user\_id INT NOT NULL,

# &#x20; accommodation DECIMAL(10,2) DEFAULT 0,

# &#x20; food DECIMAL(10,2) DEFAULT 0,

# &#x20; transport DECIMAL(10,2) DEFAULT 0,

# &#x20; attractions DECIMAL(10,2) DEFAULT 0,

# &#x20; others DECIMAL(10,2) DEFAULT 0,

# &#x20; created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

# &#x20; FOREIGN KEY (trip\_id) REFERENCES trips(id) ON DELETE CASCADE,

# &#x20; FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE

# );

# 

# CREATE TABLE wishlist (

# &#x20; id INT AUTO\_INCREMENT PRIMARY KEY,

# &#x20; user\_id INT NOT NULL,

# &#x20; destination\_id INT NOT NULL,

# &#x20; created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

# &#x20; FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE,

# &#x20; FOREIGN KEY (destination\_id) REFERENCES destinations(id) ON DELETE CASCADE

# );

# ```

# 

# \### Flutter Setup

# 

# 1\. Clone the repository:

# ```bash

# git clone https://github.com/yourusername/tripgenius.git

# cd tripgenius

# ```

# 

# 2\. Install dependencies:

# ```bash

# flutter pub get

# ```

# 

# 3\. Update the API base URL in `lib/services/auth\_service.dart` and `lib/services/api\_service.dart`:

# ```dart

# // For emulator

# static const String baseUrl = 'http://10.0.2.2/tripgenius';

# 

# // For Chrome testing

# static const String baseUrl = 'http://127.0.0.1/tripgenius';

# 

# // For real device (use your PC's local IP)

# static const String baseUrl = 'http://192.168.x.x/tripgenius';

# ```

# 

# 4\. Run the app:

# ```bash

# \# Chrome (for testing)

# flutter run -d chrome --web-browser-flag "--disable-web-security"

# 

# \# Android emulator

# flutter run -d emulator-5554

# 

# \# Real device

# flutter run

# ```

# 

# \## API Endpoints

# 

# | Method | Endpoint | Description | Auth |

# |---|---|---|---|

# | POST | `/auth.php?action=register` | Register new user | No |

# | POST | `/auth.php?action=login` | Login user | No |

# | GET | `/auth.php?action=profile` | Get user profile | Yes |

# | PUT | `/auth.php?action=profile` | Update profile | Yes |

# | POST | `/generate.php` | Generate AI itinerary | Yes |

# | GET | `/trips.php` | Get saved trips | Yes |

# | POST | `/trips.php` | Save a trip | Yes |

# | DELETE | `/trips.php?id=` | Delete a trip | Yes |

# | GET | `/destinations.php` | List destinations | No |

# | GET | `/destinations.php?id=` | Destination detail | No |

# | GET | `/destinations.php?search=` | Search destinations | No |

# | GET | `/wishlist.php` | Get wishlist | Yes |

# | POST | `/wishlist.php` | Add to wishlist | Yes |

# | DELETE | `/wishlist.php?id=` | Remove from wishlist | Yes |

# | GET | `/budget.php?trip\_id=` | Get trip budget | Yes |

# | POST | `/budget.php` | Save budget | Yes |

# | GET | `/transport.php` | Get transport info | No |

# 

# \## Screenshots

# 

# > Coming soon

# 

# \## License

# 

# MIT License — feel free to use and modify.

# 

# \## Developer

# 

# Built with ❤️ using Flutter + PHP + Gemini AI

