module.exports = {


  friendlyName: 'Get services',


  description: '',


  inputs: {

  },


  exits: {

  },


  fn: async function (inputs, exits) {

    let services = await Service.find();
    return exits.success(services);

  }


};
