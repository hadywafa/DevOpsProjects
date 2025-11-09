using Company.Utils;
using Xunit;

public class StringToolsTests
{
    [Theory]
    [InlineData("HelloWorld", 5, "Hello")]
    [InlineData("Hi", 5, "Hi")]
    [InlineData("", 3, "")]
    public void TakeFirst_Works(string input, int count, string expected)
        => Assert.Equal(expected, StringTools.TakeFirst(input, count));
}
