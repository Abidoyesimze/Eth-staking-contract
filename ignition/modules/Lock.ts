import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JAN_1ST_2030 = 1893456000;
const ONE_GWEI: bigint = 1_000_000_000n;

const stakingModule = buildModule("stakingModule", (m) => {
  const stakingTime = m.getParameter("unlockTime", JAN_1ST_2030);
  const stakingAmount = m.getParameter("stakingAmount", ONE_GWEI);

  const lock = m.contract("staking", [], {
    value: stakingAmount,
  });

  return { lock };
});

export default stakingModule;
