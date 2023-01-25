from selenium import webdriver

def enable_chrome_extension(extension_name):
    # Create a chrome driver object
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--disable-extensions-except="+extension_name)
    chrome_options.add_argument("--load-extension="+extension_name)
    driver = webdriver.Chrome(chrome_options=chrome_options)

enable_chrome_extension(path_to_extension)


def align_proteins()