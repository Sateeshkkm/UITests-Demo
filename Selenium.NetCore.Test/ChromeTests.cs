using System;
using System.IO;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using Xunit;

namespace Selenium.NetCore.Test
{
    public class ChromeTests : IDisposable
    {
        private static IWebDriver _chrome;

        public ChromeTests()
        {
            var directory = Directory.GetCurrentDirectory();
            var pathDrivers = directory + "/../../../../drivers";

            _chrome = new ChromeDriver(pathDrivers);
        }

        [Fact]
        public void GotToIndex()
        {
            Console.WriteLine("This block is executed");
            _chrome.Navigate().GoToUrl("https://google.com/");
        }

        public void Dispose()
        {
            _chrome?.Dispose();
        }
    }
}
