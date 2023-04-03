using Demo.Shared;
using NUnit.Framework;

namespace Demo.Tests;

public class Class1Fixture
{
    [Test]
    public void TestAdd()
    {
        Assert.AreEqual(3, Class1.Add(1, 2));
    }
}
