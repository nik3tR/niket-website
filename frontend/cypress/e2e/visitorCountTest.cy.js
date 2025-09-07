context("Visitor Count API Test", () => {
  const apiUrl = "https://7s6992vnf6.execute-api.us-east-1.amazonaws.com";

  it("increments visitor count correctly across multiple calls", () => {
    let initialCount;

    // First call
    cy.request("POST", apiUrl, {}).then((res) => {
      initialCount = res.body.count;
      expect(initialCount).to.be.a("number");
    });

    // Second call
    cy.request("POST", apiUrl, {}).then((res) => {
      const count2 = res.body.count;
      expect(count2).to.eq(initialCount + 1);
    });

    // Third call
    cy.request("POST", apiUrl, {}).then((res) => {
      const count3 = res.body.count;
      expect(count3).to.eq(initialCount + 2);
    });

    cy.request({method: "POST", url: apiUrl, failOnStatusCode: false}).then((res) => {
      const status = res.status;
      expect(status).to.eq(400)
    })

  });
});
